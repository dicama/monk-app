import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aes_crypt/aes_crypt.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image/image.dart' as im;
import 'package:monk/src/modules/lib/documentmanager/documentmanager.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:path/path.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/block/modes/ecb.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:uuid/uuid.dart';

import '../../tools.dart';

enum FileSysElementType { directory, file }

enum FileSysFileType { image, pdf, other }

const List<String> imageExtensions = [
  ".jpeg",
  ".jpg",
  ".bmp",
  ".png",
  ".jpeg",
  ".tga",
  ".ico",
  ".webp",
  ".tif"
];

abstract class FileSysElement {
  List<String> tags = List<String>();
  FileSysElementType type;
  DateTime creation;
  DateTime modification;
  bool isFavorite = false;
  String name;
  String _parent;
  String uid;
  bool isPreviewReady = false;
  Uint8List preview;
  Map<String, FileSysElement> _fileSystem;

  bool isDir() {
    return type == FileSysElementType.directory;
  }

  bool isFile() {
    return type == FileSysElementType.file;
  }

  bool delete() {
    if (isDir()) {
      FileSysDirectory that = this as FileSysDirectory;
      if(that._children.isEmpty) {
        getParent()._children.remove(uid);
        _fileSystem.remove(uid);
        EncryptedFS().saveFileSystem();
      }

    } else {
      FileSysFile that = this as FileSysFile;
      getParent()._children.remove(uid);
      _fileSystem.remove(uid);
      File(that.pathToEcryptedFile).delete();
      EncryptedFS().saveFileSystem();

      return true;
    }
  }

  bool checkDeleteable() {
    if (isDir()) {
      FileSysDirectory that = this as FileSysDirectory;
      if(that._children.isEmpty) {
        return true;
      }
      else
        {
          return false;
        }

    } else {

      return true;
    }
  }


  bool toggleFavorite() {
    isFavorite = !isFavorite;
    EncryptedFS().saveFileSystem();
  }

  int getNumberOfChildren() {
    if (type == FileSysElementType.file) {
      return 0;
    } else {
      FileSysDirectory that = this;
      return that._children.length;
    }
  }

  void moveTo(FileSysDirectory newParent) {
    getParent()._children.remove(uid);
    newParent._children.add(uid);
    _parent = newParent.uid;
    EncryptedFS().saveFileSystem();
  }

  String getFullPath({String add = ""}) {
    add = "/$name" + add;
    if (_parent != null) {
      return _fileSystem[_parent].getFullPath(add: add);
    } else {
      return add;
    }
  }

  FileSysDirectory getParent() {
    if (_parent == null) {
      return null;
    } else {
      return _fileSystem[_parent];
    }
  }

  Map<String, dynamic> toJson() => {
        'creation': creation.toIso8601String(),
        'modification': creation.toIso8601String(),
        'parent': _parent,
        'name': name,
        'uid': uid,
        'tags': tags,
        'type': type.index,
        "preReady": isPreviewReady ? 1 : 0,
        "pre": isPreviewReady ? base64.encode(preview) : "",
        "favorite": isFavorite ? 1 : 0,
      };

  FileSysElement(DateTime dob, String filname, FileSysDirectory parentDir) {
    creation = dob;
    name = filname;
    _parent = parentDir.uid;
    uid = Uuid().v4();
    _fileSystem = parentDir._fileSystem;
  }

  FileSysElement.MakeRoot(
      DateTime dob, String dirname, Map<String, FileSysElement> fileSystem) {
    creation = dob;
    name = dirname;
    uid = "root";
    type = FileSysElementType.directory;
    _fileSystem = fileSystem;
  }

  int compareTo(FileSysElement b) {
    if (type != b.type) {
      if (type == FileSysElementType.file) {
        return 1;
      } else {
        return -1;
      }
    } else {
      return name.compareTo(b.name);
    }
  }

  void edit(String newName, List<String> newTags) {
    name = newName;
    tags = newTags;
    EncryptedFS().saveFileSystem();
  }

  FileSysElement.fromJson(
      Map<String, dynamic> json, Map<String, FileSysElement> fileSystem) {
    creation = DateTime.parse(json['creation']);
    _parent = json['parent'];
    name = json["name"];
    uid = json["uid"];
    tags = List<String>.from(json['tags']);
    type = FileSysElementType.values[json['type']];
    isPreviewReady = json["preReady"] == 1 ? true : false;
    isFavorite = json["favorite"] == 1 ? true : false;
    preview = isPreviewReady ? base64.decode(json["pre"]) : null;
    _fileSystem = fileSystem;
    _fileSystem[uid] = this;
  }
}

class FileSysFile extends FileSysElement {
  String pathToEcryptedFile;
  FileSysFileType fileType = FileSysFileType.other;

  FileSysFile.fromJson(
      Map<String, dynamic> json, Map<String, FileSysElement> fileSystem)
      : super.fromJson(json, fileSystem) {
    pathToEcryptedFile = json["eFile"];
    fileType = FileSysFileType.values[json["fileType"]];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = super.toJson();

    ret["eFile"] = pathToEcryptedFile;
    ret["fileType"] = fileType.index;
    return ret;
  }

  FileSysFile(dob, filename, FileSysDirectory parentDir, String localTempFile)
      : super(dob, filename, parentDir) {
    var imageFile = File(localTempFile);
    type = FileSysElementType.file;
    im.Image image = im.decodeImage(File('test.webp').readAsBytesSync());

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    preview = im.encodePng(im.copyResize(image, width: 120));
    isPreviewReady = true;
    EncryptedFS().saveFileSystem();

    // Save the thumbnail as a PNG.
  }

  FileSysFile.fromBytesImg(
      dob, filename, FileSysDirectory parentDir, Uint8List byteData)
      : super(dob, filename, parentDir) {
    type = FileSysElementType.file;
    fileType = FileSysFileType.image;
    pathToEcryptedFile = EncryptedFS().saveEncryptedFile(uid, byteData);

    im.Image image = im.decodeImage(byteData);
    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    preview = im.encodePng(im.copyResize(image, width: 120));
    isPreviewReady = true;
    EncryptedFS().saveFileSystem();

    // Save the thumbnail as a PNG.
  }

  createPDFPreview(Uint8List byteData) async {
    final document = await PdfDocument.openData(byteData);
    final page = await document.getPage(1);
    final pageImage =
        await page.render(width: page.width * 4, height: page.height * 4);

    im.Image image = im.decodeImage(pageImage.bytes);
    preview = im.encodePng(im.copyResize(image, width: 120));
    isPreviewReady = true;
    EncryptedFS().saveFileSystem();
  }

  FileSysFile.fromFile(dob, filename, FileSysDirectory parentDir, File fil,
      {List<String> fileTags = const []})
      : super(dob, filename, parentDir) {
    type = FileSysElementType.file;
    tags = fileTags;
    String ext = extension(fil.path).toLowerCase();
    if (ext == ".pdf") {
      fileType = FileSysFileType.pdf;
      fil.readAsBytes().then((byteData) {
        createPDFPreview(byteData);
        pathToEcryptedFile = EncryptedFS().saveEncryptedFile(uid, byteData);
      });
    } else if (imageExtensions.contains(ext)) {
      fileType = FileSysFileType.image;
      fil.readAsBytes().then((byteData) {
        im.Image image = im.decodeImage(byteData);
        // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
        pathToEcryptedFile = EncryptedFS().saveEncryptedFile(uid, byteData);
        preview = im.encodePng(im.copyResize(image, width: 120));
        isPreviewReady = true;
      });
    }
  }

  FileSysFile.fromBytesPDF(
      dob, filename, FileSysDirectory parentDir, Uint8List byteData,
      {List<String> fileTags = const []})
      : super(dob, filename, parentDir) {
    type = FileSysElementType.file;
    fileType = FileSysFileType.pdf;
    tags = fileTags;

    createPDFPreview(byteData);
    pathToEcryptedFile = EncryptedFS().saveEncryptedFile(uid, byteData);

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    // Save the thumbnail as a PNG.
  }
}

class FileSysDirectory extends FileSysElement {
  List<String> _children = List();
  Color classColor = Colors.grey;

  FileSysDirectory.fromJson(
      Map<String, dynamic> json, Map<String, FileSysElement> fileSystem)
      : super.fromJson(json, fileSystem) {
    _children = List<String>.from(json['children']);
    classColor = Color(json['classColor']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = super.toJson();
    ret['classColor'] = classColor.value;
    ret['children'] = _children;

    return ret;
  }

  FileSysDirectory(dob, dirname, FileSysDirectory parentDir,
      {Color classCol = Colors.grey})
      : super(dob, dirname, parentDir) {
    type = FileSysElementType.directory;
    classColor = classCol;
  }

  FileSysDirectory.MakeRoot(
      DateTime dob, String dirname, Map<String, FileSysElement> fileSystem)
      : super.MakeRoot(dob, dirname, fileSystem) {}

  addFile(FileSysElement file) {
    file._fileSystem = _fileSystem;
    _children.add(file.uid);
    _fileSystem[file.uid] = file;
    EncryptedFS().registerELement(file);
    EncryptedFS().saveFileSystem();
  }

  addDir(FileSysDirectory dir) {
    if (!hasDir(dir.name)) {
      dir._fileSystem = _fileSystem;
      _children.add(dir.uid);
      _fileSystem[dir.uid] = dir;
      EncryptedFS().registerELement(dir);
      EncryptedFS().saveFileSystem();
    }
  }

  hasDir(String dirName) {
    if (_children
            .indexWhere((element) => _fileSystem[element].name == dirName) >
        -1) {
      return true;
    } else {
      return false;
    }
  }

  List<FileSysElement> getChildren() {
    List<FileSysElement> children =
        _children.map((e) => _fileSystem[e]).toList();
    children.sort((FileSysElement a, FileSysElement b) => a.compareTo(b));

    return children;
  }

  List<FileSysDirectory> getChildrenDirs() {
    List<FileSysDirectory> listDirs = List();

    _children.forEach((element) {
      if (_fileSystem[element].type == FileSysElementType.directory) {
        listDirs.add(_fileSystem[element]);
      }
    });

    listDirs.sort((a, b) => a.compareTo(b));

    return listDirs;
  }

  FileSysDirectory getChildDirWithName(String searchName) {
    for (var element in _children) {
      if ((_fileSystem[element].type == FileSysElementType.directory) &&
          (_fileSystem[element].name == searchName)) {
        return _fileSystem[element];
      }
    }
    return null;
  }
}

class EncryptedFS {
  static final EncryptedFS _instance = EncryptedFS._internal();
  AesCrypt crypt = AesCrypt("MeaninglessPwd");
  String version;
  BlockCipher cipher = CBCBlockCipher(AESFastEngine());
  BlockCipher decipher = CBCBlockCipher(AESFastEngine());
  var credentials;
  StreamController<String> saveStream =
      new StreamController<String>.broadcast();
  StreamController<String> createStream =
      new StreamController<String>.broadcast();

  factory EncryptedFS() => _instance;
  final secureStorage = new FlutterSecureStorage();
  List<FileSysDirectory> dirs = List();
  Map<String, FileSysElement> files = Map();
  SortedMap<String, int> tagCloud = SortedMap(Ordering.byValue());
  String pathToEnc;

  EncryptedFS._internal() {
    version = "0.0013";
  }

  List<String> getTopKTags(int number, {List<String> excludeTags: const []}) {
    List<String> filtered = List();
    tagCloud.keys.toList().forEach((element) {
      if (!excludeTags.contains(element)) {
        filtered.add(element);
      }
    });

    return filtered.take(number).toList();
  }

  saveFileSystem() {
    AccessLayer()
        .setData(DocumentManagerModule.documentManagerId, "filesystem", files.values.map((e) => e.toJson()).toList());
    AccessLayer().setData(DocumentManagerModule.documentManagerId, "filesystemver", version);
    saveStream.add("filesystem");
  }

  String saveEncryptedFileAlt(String uid, Uint8List data) {
    crypt.encryptDataToFile(data, pathToEnc + "/" + uid);

    return pathToEnc + "/" + uid;
  }

  String saveEncryptedFile(String uid, Uint8List data) {
    cipher = CBCBlockCipher(AESFastEngine());
    var iv = enc.IV.fromBase64(credentials['iv']);
    var key = enc.Key.fromUtf8(credentials['key']);

    cipher.init(true, ParametersWithIV(KeyParameter(key.bytes), iv.bytes));

    File file = File(pathToEnc + "/" + uid);
    double size = (data.length / cipher.blockSize);
    int padding = size.ceil() * cipher.blockSize - data.length;
    ByteData bytesIn = ByteData(data.length + padding);
    ByteData bytesOut = ByteData(2 + data.length + padding);
    bytesOut.setInt16(0, padding);
    var list8 = bytesIn.buffer.asUint8List(0, data.length + padding);
    list8.setRange(0, data.length, data);
    var list8out = bytesOut.buffer.asUint8List(0, data.length + padding + 2);
    for (int i = 0; i < size.ceil(); i++) {
      cipher.processBlock(
          list8, i * cipher.blockSize, list8out, i * cipher.blockSize + 2);
    }

    file.writeAsBytes(list8out);

    return pathToEnc + "/" + uid;
  }

  Uint8List loadEncryptedFile(String uid) {
    decipher = CBCBlockCipher(AESFastEngine());
    var iv = enc.IV.fromBase64(credentials['iv']);
    var key = enc.Key.fromUtf8(credentials['key']);
    decipher.init(false, ParametersWithIV(KeyParameter(key.bytes), iv.bytes));

    File file = File(pathToEnc + "/" + uid);
    ByteData raw = file.readAsBytesSync().buffer.asByteData();
    int padding = raw.getInt16(0);
    int paddedoutputsize = raw.lengthInBytes - 2;
    double size = (paddedoutputsize / decipher.blockSize);
    ByteData outbuff = ByteData(paddedoutputsize);

    Uint8List list8in = raw.buffer.asUint8List(2, paddedoutputsize);
    Uint8List list8out = outbuff.buffer.asUint8List(0, paddedoutputsize);

    for (int i = 0; i < size.ceil(); i++) {
      decipher.processBlock(
          list8in, i * decipher.blockSize, list8out, i * decipher.blockSize);
    }
    int outputsize = raw.lengthInBytes - padding - 2;
    return outbuff.buffer.asUint8List(0, outputsize);
  }

  Uint8List loadEncryptedFileAlt(String uid) {
    return crypt.decryptDataFromFileSync(pathToEnc + "/" + uid);
  }

  registerELement(FileSysElement sysElement) {
    sysElement.tags.forEach((element) {
      if (tagCloud.containsKey(element)) {
        tagCloud[element]++;
      } else {
        tagCloud[element] = 1;
      }
    });
  }

  List<FileSysElement> findFiles(String pattern, {bool isFavorite = false}) {
    List<FileSysElement> resList = List<FileSysElement>();
    List<FileSysElement> searchbase;

    if (isFavorite) {
      searchbase = getFavorites();
    } else {
      searchbase = files.values.toList();
    }
    searchbase.forEach((value) {
      if (value.name.toLowerCase().contains(pattern)) {
        resList.add(value);
      } else if (value.tags.join(",").contains(pattern)) {
        resList.add(value);
      }
    });

    return resList;
  }

  loadFileSystem() {
    files = Map<String, FileSysElement>();
    var lsFiles = AccessLayer().getData(DocumentManagerModule.documentManagerId, "filesystem");
    var lsVersion = AccessLayer().getData(DocumentManagerModule.documentManagerId, "filesystemver");
    /*print(lsFiles.toString());*/

    if (lsFiles == null || lsVersion == null || lsVersion != version) {
      FileSysDirectory root =
          FileSysDirectory.MakeRoot(DateTime.now(), "MONK", files);
      files["root"] = root;
      root.addDir(FileSysDirectory(DateTime.now(), "Laborwerte", root,
          classCol: Colors.red));
      root.addDir(FileSysDirectory(DateTime.now(), "Arztbriefe", root,
          classCol: Colors.green));
      root.addDir(FileSysDirectory(DateTime.now(), "X-ray", root));
      root.addDir(FileSysDirectory(DateTime.now(), "Zweitmeinungen", root,
          classCol: Colors.orange));
    } else {
      lsFiles.forEach((element) {
        if (FileSysElementType.values[element["type"]] ==
            FileSysElementType.directory) {
          files[element["uid"]] = FileSysDirectory.fromJson(element, files);
        } else {
          files[element["uid"]] = FileSysFile.fromJson(element, files);
          files[element["uid"]].tags.forEach((element) {
            if (tagCloud.containsKey(element)) {
              tagCloud[element]++;
            } else {
              tagCloud[element] = 1;
            }
          });
        }
      });
    }
  }

  List<FileSysFile> getRecentlyAddedFiles(int number) {
    List<FileSysFile> recents = List();
    files.forEach((key, value) {
      if (value.isFile()) {
        recents.add(value);
      }
    });
    recents.sort((a, b) =>
        b.creation.millisecondsSinceEpoch - a.creation.millisecondsSinceEpoch);
    return recents.take(number).toList();
  }

  List<FileSysElement> getFavorites() {
    List<FileSysElement> favs = List();
    files.forEach((key, value) {
      if (value.isFavorite) {
        favs.add(value);
      }
    });
    favs.sort((a, b) => a.compareTo(b));
    return favs;
  }

  FileSysDirectory getRoot() {
    FileSysDirectory root =
        files.values.firstWhere((element) => element.getParent() == null);
    return root;
  }

  void cleanup() async {
    var encfiles = Directory(pathToEnc).listSync();
    encfiles.forEach((element) {
      var base = basename(element.path);
      if (!files.keys.contains(base)) {
        print("lost:" + base);
        print("deleting:" + base);
        File(element.path).delete();
      }
    });
  }

  init() async {
    AccessLayer().register(DocumentManagerModule.documentManagerId, "filesystem", "Dateisystem", "Dateien des Dokumentenmanagers");
    AccessLayer().register(DocumentManagerModule.documentManagerId, "filesystemver", "Dateisystem-Version", "Version des Dateisystems");

    Stopwatch stopwatch = new Stopwatch()..start();
    credentials = jsonDecode(await secureStorage.read(key: 'monk.credentials'));

    var iv = enc.IV.fromBase64(credentials['iv']);
    var key = enc.Key.fromUtf8(credentials['key']);

    cipher.init(true, ParametersWithIV(KeyParameter(key.bytes), iv.bytes));

    decipher.init(false, ParametersWithIV(KeyParameter(key.bytes), iv.bytes));

    crypt.aesSetKeys(key.bytes, iv.bytes);
    pathToEnc = await createFolderInAppDocDir("encryptedFiles");
    loadFileSystem();

    cleanup(); // cleanup files in encrypted folder
    debugPrint('EncryptedFilesystem inititated in ${stopwatch.elapsed}');
  }
}
