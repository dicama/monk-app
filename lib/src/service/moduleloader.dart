import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:monk/src/modules/basicmodule.dart';
import 'package:monk/src/modules/lib/documentmanager/documentmanager.dart';
import 'package:monk/src/modules/lib/pilltracker/pilltracker.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/modules/modulewidget.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppStoreModule {
  AppStoreModule(this.fileName, this.localPath, this.sha, this.isAssetApp, { this.iconUrl });

  final String sha;
  final String fileName;
  final String localPath;
  final bool isAssetApp;
  String iconUrl;
}

class ModuleLoader {
  static final ModuleLoader _instance = ModuleLoader._internal();

  final String appStoreDir = "appstore";
  final String moduleDir = "modules";
  final String gitHubUrl = "https://api.github.com/repos/dicama/monk-modules/contents/modules";
  final String gitHubRef = "?ref=main";
  final String templateFileEnding = ".txt";

  final List<String> assetApps = ["module1.txt","module2.txt","module3.txt","module4.txt", "module5.txt"];
  factory ModuleLoader() => _instance;
  StreamController<String> moduleChange = new StreamController<String>.broadcast();

  bool loaded = false;
  List<BasicModule> modules = new List<BasicModule>();
  List<String> moduleOrder = new List<String>();
  List<AppStoreModule> appStoreIndex = List<AppStoreModule>();
  Map<String, String> appStoreCache = Map<String, String>();
  List<String> appStoreInstalled = ["module2.txt","module3.txt","module4.txt"];

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  ModuleLoader._internal() {}

  Future<http.Response> fetchList() {
    return http.get(Uri.parse(gitHubUrl + gitHubRef));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory(
        '${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder
        .exists()) { //if folder already exists return path
      return _appDocDirFolder.path;
    } else { //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(
          recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  Future<http.Response> fetchModule(var url) {
    return http.get(url);
  }

  void syncAppStore() async {
    assetApps.forEach((element) async {
      if(appStoreIndex.indexWhere((item) => item.fileName == element)==-1) {
        appStoreIndex.add(AppStoreModule(
            element, 'assets/res/modules/$element', "none", true));
        appStoreCache[element] =
        await getFileData("assets/res/modules/$element");
      }
    });

    var resp = await fetchList();
    if (resp.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var j1 = jsonDecode(resp.body);
      for (var i = 0; i < j1.length; i++) {
        String filename1 = j1[i]["name"];
        if (!filename1.endsWith(templateFileEnding)) {
          continue;
        }
        var sha = j1[i]["sha"];
        print("syncing " + filename1);
        int ind =
        appStoreIndex.indexWhere((item) => item.fileName == filename1);
        if (ind > -1) {
          if (appStoreIndex[ind].sha != sha) {
            var mod = await fetchModule(j1[i]["download_url"]);
            print(mod.body);
            appStoreCache[filename1] = mod.body;
            var path = await createFolderInAppDocDir(appStoreDir);
            await File('$path/$filename1').writeAsString(mod.body);
            String iconUrl = await _loadIconUrl("$filename1");

            appStoreIndex[ind] =
                AppStoreModule(filename1, '$path/$appStoreDir/$filename1', sha, false, iconUrl: iconUrl);
          }
        } else {
          var mod = await fetchModule(j1[i]["download_url"]);
          print(mod.body);
          appStoreCache[filename1] = mod.body;
          var path = await createFolderInAppDocDir(appStoreDir);
          await File('$path/$filename1').writeAsString(mod.body);
          String iconUrl = await _loadIconUrl("$filename1");
          appStoreIndex.add(
              AppStoreModule(filename1, '$path/$appStoreDir/$filename1', sha, false, iconUrl: iconUrl));
        }
        var path = await createFolderInAppDocDir(appStoreDir);
        List<FileSystemEntity> oops =  Directory("$path").listSync();
        oops.forEach((element) async {
          print(element.path);
           String p= basename(element.path);
          if(appStoreIndex.firstWhere( (el) => el.fileName == p, orElse: () => null) == null)
            {
              element.delete(recursive: true);
            }
        });
      }
    } else {
      print("statuscode " + resp.statusCode.toString());
    }
    print("done syncing");
  }

  _getFileNameWithoutEnding(String fileName) {
    if (fileName.endsWith(templateFileEnding)) {
      fileName = fileName.substring(0, fileName.length - templateFileEnding.length);
    }
    return fileName;
  }

  Future<String> _loadIconUrl(String moduleName) async {
    moduleName = _getFileNameWithoutEnding(moduleName);

    var resp = await http.get(Uri.parse(gitHubUrl + "/" + moduleName + "/assets/icon.svg" + gitHubRef));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)["download_url"];
    }
    return null;
  }

  // TODO ggf. kann das später gleich für den Download beim "hinzufügen des Moduls verwendet werden"
  _loadIcon(String moduleName, String modulePath) async {
    moduleName = _getFileNameWithoutEnding(moduleName);

    var resp = await http.get(Uri.parse(gitHubUrl + "/" + moduleName + "/assets/icon.svg" + gitHubRef));
    if (resp.statusCode == 200) {
      var downloadUrl = jsonDecode(resp.body)["download_url"];
      var download = await http.get(downloadUrl);
      if (download.statusCode == 200) {
        var file = await File('$modulePath/$moduleName/assets/icon.svg');
        file.createSync(recursive: true);
        print('loadIcon before ' + file.toString());
        file.writeAsString(download.body);
        print('loadIcon after');
      } else {
        print('loading icon failed from ' + downloadUrl + ", statuscode: " + download.statusCode.toString());
      }
    } else {
      print('loading icon failed from ' + gitHubUrl + "/" + moduleName + "/assets/icon.svg" + gitHubRef + ", statuscode: " + resp.statusCode.toString());
    }
  }

  removeModule(String filename) {
    appStoreInstalled.remove(filename);
    saveInstalledApps();
    loadModules(force: true);
  }

  addModule(String filename) async {

    //TODO Basti Daten für Popup laden (Modulname, Modultext, Lesezugriffe)
    //in Popup dann bestätigung für Zugriff und Modul hinzufügen holen
    //ggf. muss das auch schon im AppStore passieren?

    var path = await _localPath;
    await createFolderInAppDocDir(moduleDir);
    _loadIcon(filename, "$path/$moduleDir");
    appStoreInstalled.add(filename);
    saveInstalledApps();
    loadModules(force: true);
  }

  setAppOrder(List<String> names) {
    moduleOrder = names;
    AccessLayer().setData("GENERAL", "moduleorder", moduleOrder);
  }

  void loadAppOrder() {
    List<String> tempModules = List<String>();
    modules.forEach((element) {
      tempModules.add(element.name);
    });
    var dataLayerStr = AccessLayer().getData("GENERAL", "moduleorder");
    List<String> tempModOrder;
    if (dataLayerStr != null) {
      tempModOrder = (AccessLayer().getData("GENERAL", "moduleorder")).cast<
          String>().toList();
    }
    if(tempModOrder != null) {
      moduleOrder = List<String>();
      tempModOrder.forEach((element) {
        if (tempModules.contains(element)) {
          moduleOrder.add(element);
          tempModules.remove(element);
        }
      });
      tempModules.forEach((element) {
        moduleOrder.add(element);
      });
    }
    else
      {
        moduleOrder = tempModules;
        setAppOrder(moduleOrder);
      }

  }

  void loadInstalledApps() {
    if (AccessLayer().getData("GENERAL", "modulesinstalled") == null) {
      AccessLayer().setData("GENERAL", "modulesinstalled", appStoreInstalled);
    } else {
      appStoreInstalled =
          (AccessLayer().getData("GENERAL", "modulesinstalled")).cast<String>().toList();
    }
  }

  void saveInstalledApps() {
    AccessLayer().setData("GENERAL", "modulesinstalled", appStoreInstalled);
  }


  List<Widget> getDashboardWidgets(BuildContext context, {bool isCompact = false}) {
    List<Widget> dash = new List<Widget>();

    modules.forEach((element) {
      dash.add(element.getDashboardWidget(context, isCompact: isCompact));
    });

    return dash;
  }

  Map<String, Widget> getDashboardWidgetsMap(BuildContext context, {bool isCompact = false}) {
    Map<String, Widget> dash = new Map();

    modules.forEach((element) {
      dash[element.name] = element.getDashboardWidget(context, isCompact: isCompact);
    });

    return dash;
  }

  List<String> getModuleNames() {
    List<String> dash = new List();
    modules.forEach((element) {
      dash.add(element.name);
    });
    return dash;
  }

  Column getMenuWidgets(BuildContext context) {
    List<Widget> list = new List<Widget>();
    modules.forEach((element) {
      list.add(ListTile(
        leading: element.getModuleIcon(),
        title: Text(element.name),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ModuleWidget(element)),
          );
        },
      ));
    });

    return Column(children: list);
  }

  void loadAppStoreModule(String fileName) async {
    if(assetApps.contains(fileName)) {
        final String data = await getFileData("assets/res/modules/$fileName");
        modules.add(new Module(data, filename: fileName));
        moduleOrder.add(modules.last.name);
    } else {
      var path = await _localPath;
      var data = await File("$path/$appStoreDir/$fileName").readAsString();

      var fileNameWithoutEnding = _getFileNameWithoutEnding(fileName);
      var icon = await File("$path/$moduleDir/$fileNameWithoutEnding/assets/icon.svg");
      String iconUrl;
      if (icon.existsSync()) {
        iconUrl = "$path/$moduleDir/$fileNameWithoutEnding/assets/icon.svg";
      }
      modules.add(new Module(data, filename: fileName, iconUrl1: iconUrl));
      moduleOrder.add(modules.last.name);
    }
  }

  void loadModules({force = false}) async {

    Stopwatch stopwatch = new Stopwatch()..start();
    if (!loaded || force) {
      initData();
      loadInstalledApps();
      modules = new List<BasicModule>();
      await appStoreInstalled.forEach((element) async {
        await loadAppStoreModule(element);
      });
      modules.add(DocumentManagerModule());
      modules.add(PillTrackerModule());

      loadAppOrder();
      loaded = true;
      moduleChange.add("apps loaded");
      /*modules.forEach((element) {
        NotificationManager().add(NotificationItem(
            "Willkommen bei ${element.name} klicke um das Modul zu benutzen",
            element.icon,
            element,
            DateTime.now(),
            "Willkommen"));
      });*/
    }
    print('ModuleLoading took ${stopwatch.elapsed}');
  }

  initData() {
    /*var poopseries = [ {"date": DateTime.now().toIso8601String(), "consistency": "consistenz", "color": Colors.brown.value, "stool": true, "pain": true}];*/

    /*DataLayer().setData("poopseries", poopseries);*/
  }
}
