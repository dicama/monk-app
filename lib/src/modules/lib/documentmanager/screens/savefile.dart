import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monk/src/customwidgets/addabletags.dart';
import 'package:monk/src/customwidgets/fileexplorer.dart';
import 'package:monk/src/pdf_templates/pdfgenerator.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:path/path.dart' show basename;

import '../documentmanager.dart';

class SaveFileScreen extends StatefulWidget {
  final List<Uint8List> bundle;
  final File file;
  final FileSysDirectory fixedFolder;


  const SaveFileScreen(this.bundle, {this.fixedFolder = null}) : this.file = null;

  const SaveFileScreen.forFile(this.file, {this.fixedFolder = null}) : this.bundle = null;

  @override
  SaveFileScreenState createState() => SaveFileScreenState();
}

class SaveFileScreenState extends State<SaveFileScreen> {
  File imageFile;
  List<String> selectedTags = List();
  TextEditingController folderController =
      TextEditingController(text: "New Folder");
  TextEditingController _filenameController = TextEditingController(
      text: DateFormat()
              .add_yMd()
              .add_Hms()
              .format(DateTime.now())
              .replaceAll("/", "_")
              .replaceAll(" ", "_")
              .replaceAll(":", "_") +
          ".pdf");
  FileSysDirectory currentDir;

  @override
  Future<void> initState() {
    super.initState();
    // To display the current output from the Camera,
    if (widget.file != null) {
      _filenameController.text = basename(widget.file.path);
    }

    if(widget.fixedFolder != null)
      {
        currentDir = widget.fixedFolder;
        print("Taking fixed dir");
      }
    else {
      currentDir = EncryptedFS().getRoot();
    }
    // Next, initialize the controller. This returns a Future.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Save in Monk'),
            actions: [IconButton(icon: Icon(Icons.drive_file_rename_outline))]),
        bottomNavigationBar: BottomAppBar(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.library_add),
                  onPressed: () {},
                ),
                FlatButton(
                    child: Text("SPEICHERN"),
                    onPressed: () async {
                      if (widget.bundle != null) {
                        currentDir.addFile(FileSysFile.fromBytesPDF(
                            DateTime.now(),
                            _filenameController.text,
                            currentDir,
                            await PDFGenerator.generatePDFFromImages(
                                widget.bundle),
                            fileTags: selectedTags));

                        var count = 0;

                        AccessLayer().setModuleData(DocumentManagerModule.documentManagerId, "last_entry", DateTime.now().toIso8601String());

                        Navigator.popUntil(context, (route) {
                          return count++ == 3;
                        });
                      } else if (widget.file != null) {
                        currentDir.addFile(FileSysFile.fromFile(DateTime.now(),
                            _filenameController.text, currentDir, widget.file,
                            fileTags: selectedTags));

                        AccessLayer().setModuleData(DocumentManagerModule.documentManagerId, "last_entry", DateTime.now().toIso8601String());
                        Navigator.pop(context);
                      }
                    })
              ]),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _filenameController,
              )),
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                Expanded(
                    child: Text("Zielordner auswählen",
                        style: Theme.of(context).textTheme.subtitle1)),
                IconButton(
                    icon: Icon(Icons.create_new_folder),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              //this right here
                              content: TextField(controller: folderController),
                              actions: [
                                FlatButton(
                                    child: Text("Abbrechen"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                FlatButton(
                                  child: Text("Erstellen"),
                                  onPressed: () {
                                    setState(() {
                                      currentDir.addDir(FileSysDirectory(
                                          DateTime.now(),
                                          folderController.text,
                                          currentDir));
                                    });
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    })
              ])),
          Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(currentDir.getFullPath(),
                  style: Theme.of(context).textTheme.caption),
              alignment: Alignment.centerLeft),
          FileExplorerWidget(
            currentDir,
            onChangeElement: (fileElement) {
              setState(() {
                currentDir = fileElement;
              });
            },
            dirsOnly: true,
          ),
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text("Schlüsselwörter auswählen",
                  style: Theme.of(context).textTheme.subtitle1),
              alignment: Alignment.centerLeft),
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AddableTagsWidget(
                EncryptedFS().getTopKTags(5),
                onSelection: (sel) {
                  selectedTags = sel;
                  print(selectedTags);
                },
              )),
        ]))
        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializin
        );
  }
}
