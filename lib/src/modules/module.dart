import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:monk/src/service/accesslayer.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monk/src/pdf_templates/pdfgenerator.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:monk/src/templates/generator.dart';
import 'package:path_provider/path_provider.dart';
import 'basicmodule.dart';
import 'modal.dart';

class ModuleAction {
  ModuleAction(this.onEvent, this.key, this.action);

  final String onEvent;
  final String key;
  final String action;
}

class Module extends BasicModule {
  List<List<Widget>> widg = new List<List<Widget>>();
  List<Widget> dashWidg = new List<Widget>();
  List<String> tabTitles = new List<String>();
  var modals = new Map();
  var modalBundles = new Map<String, ModalBundle>();
  var actions = new List<ModuleAction>();

  String lastAccess = "";
  String fabwidget = "";
  String PDFReportString = "";
  var locals = new Map();
  bool first = true;
  bool tabbed = false;

  String filename = "";

  Module(String input, {this.filename, iconUrl1}) {
    Stopwatch stopwatch = new Stopwatch()..start();

    iconUrl = iconUrl1;
    id = getModuleId(input);
    if (input.contains('PDFReport')) {
      List<String> tokens = input.split('PDFReport');
      PDFReportString = tokens[1];
      //print("PDFReport*****************************************");
      //print(PDFReportString);
      parseModule(tokens[0]);
    } else {
      parseModule(input);
    }

    if (addresses != null) {
      for (AddressOwnerAttempt address in addresses) {
        AccessLayer()
            .register(id, address.address, address.label, address.description);
      }
    }
    if (readAccess != null) {
      for (AddressAccessAttempt address in readAccess) {
        AccessLayer()
            .registerReadAccess(id, address.address, address.description);
      }
    }
    print('Module ${name} took ${stopwatch.elapsed}');
  }

  Widget buildModule(BuildContext context, UpdateVoidFunction updateCallback) {
    return null; //should never be called.
  }

  parseModule(String input) {
    if (input.contains('Tab')) {
      List<String> tokens = input.split('Tab');
      getModals(tokens[0], id);
      for (var i = 1; i < tokens.length; i++) {
        widg.add(new List<Widget>());
        tabTitles.add(BasicElement.getInnerString(
            tokens[i].substring(0, tokens[i].indexOf('\n')), '[', ']'));
        //print(tabTitles.last);
        //print(tokens[i]);
        widg[i - 1] = WidgetGenerator.parseStringMeta(tokens[i], null, id);
      }
      tabbed = true;
    } else {
      List<String> tokens = input.split('Page');
      getModals(tokens[0], id);
      String pageInfo = tokens[1].substring(0, tokens[1].indexOf('\n'));
      if (pageInfo.contains(']')) {
        var opts = BasicElement.getOptions(pageInfo);
        if (opts["base"] == "column") {
          base = "column";
          print("It is a column");
        }
      }
      for (var i = 1; i < tokens.length; i++) {
        widg.add(new List<Widget>());
        //print(tokens[i]);
        widg[0] = WidgetGenerator.parseStringMeta(tokens[i], null, id);
      }
    }
  }

  void runModal(ModalBundle mb, Map params, BuildContext context) {
    Map newOptions = Map();
    newOptions.addAll(mb.options);
    newOptions.addAll(params);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              new Modal(mb.input, mb.moduleId, newOptions, locals: locals),
        ));
  }

  void getModals(String input, String moduleId) {
    List<String> tokens = input.split('Modal');
    parseDashWidget(tokens[0]);
    for (var i = 1; i < tokens.length; i++) {
      Map options = BasicElement.getOptions(tokens[i]);
      String name = options["title"];
      modalBundles[name] = new ModalBundle(tokens[i], moduleId, options);
    }
  }

  void parseDashWidget(String input) {
    List<String> tokens = input.split('DashboardWidget');
    getHeader(tokens[0]);

    if (hasFABAction()) {
      dashWidg.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          height: 1.0,
          color: Color.fromRGBO(226, 224, 228, 1),
        ),
      ));
    }
    if (tokens.length > 1) {
      dashWidg.addAll(WidgetGenerator.parseStringMeta(tokens[1], null, id));
    }
  }

  void performAction(ModuleAction action, BuildContext context) {
    String actionID;
    Map params;
    print(action.action);
    if (action.action.contains(":")) {
      List<String> actionbundle = action.action.split(":");
      print(actionbundle[0]);
      print(actionbundle[1]);
      actionID = actionbundle[0];
      params = BasicElement.getOptionsInner(actionbundle[1]);
    } else {
      actionID = action.action;
      params = Map();
    }
    print("params extracted");
    print(actionID);
    runModal(modalBundles[actionID], params, context);
  }

  void handleNotification(BasicElementNotification not, BuildContext context) {
    print("notification received");
    if (not.type == BasicElementNotificationType.Action) {
      actions.forEach((element) {
        if (element.key == not.key) {
          performAction(element, context);
        }
      });
    }
  }

  bool hasFABAction() {
    bool hasFAB = false;
    actions.forEach((element) {
      if (element.key == "FAB") {
        hasFAB = true;
      }
    });

    return hasFAB;
  }

  Future<String> get _tempPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.pdf');
  }

  Future<void> writeToFile(Uint8List data, String path) {
    return File(path).writeAsBytes(data);
  }

  void bottomNavBarTap(index, BuildContext bc) {
    switch (index) {
      case 0:
        break;
      case 1:
        showDialog(
            context: bc,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Info'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(moduleInfo),
                    ],
                  ),
                ),
              );
            });
        break;
      case 2:
        if (PDFReportString != "") {
          print(PDFReportString);

          PDFGenerator.generatePDF(PDFReportString, id).then((pdfdata) {
            String filename = "MRP_" +
                name.replaceAll(" ", "_") +
                "_" +
                DateFormat().addPattern("dd_MM_yy").format(DateTime.now()) +
                ".pdf";
            _tempPath.then((path) async {
              String fullname = "$path/${filename}";
              await writeToFile(pdfdata, fullname);
              Share.shareFiles(
                [fullname],
                text: 'Hello, check your share files!',
              ).then((value) {
                File tempFile = File(fullname);
                tempFile.delete();
              });
            });
          });
        }
        break;
      case 3:
        break;
    }
  }

  Function getFABAction(BuildContext bc, UpdateVoidFunction callbackVoid) {
    Function ret = () {
      print("browse actions");
      actions.forEach((element) {
        print(element.key);
        if (element.key == "FAB") {
          final ModuleAction ac = element;

          performAction(ac, bc);
          print("returning");
          return;
        }
      });

      return;
    };
    return ret;
  }

  static String getModuleName(String input) {
    List<String> tokens = input.split("\n");
    var name;
    tokens.forEach((element) {
      if (element.startsWith("ModuleName")) {
        name = BasicElement.getInnerString(element, "[", "]");
      }
    });

    return name;
  }

  static String getModuleInfo(String input) {
    List<String> tokens = input.split("\n");
    var name;
    tokens.forEach((element) {
      if (element.startsWith("ModuleInfo")) {
        name = BasicElement.getInnerString(element, "[", "]");
      }
    });

    return name;
  }

  static String getModuleId(String input) {
    List<String> tokens = input.split("\n");
    var id;
    tokens.forEach((element) {
      if (element.startsWith("ModuleId")) {
        id = BasicElement.getInnerString(element, "[", "]");
      }
    });

    return id;
  }

  static String getModuleIconQuick(String input) {
    List<String> tokens = input.split("\n");
    var name;
    tokens.forEach((element) {
      if (element.startsWith("ModuleIcon")) {
        name = BasicElement.getInnerString(element, "[", "]");
      }
    });

    return name;
  }

  static getModuleVersionQuick(String input) {
    List<String> tokens = input.split("\n");
    var name;
    tokens.forEach((element) {
      if (element.startsWith("ModuleVersion")) {
        name = BasicElement.getInnerString(element, "[", "]");
      }
    });

    return name;
  }

  void getHeader(String input) {
    AccessLayer accessLayer = AccessLayer();

    List<String> tokens = input.split("\n");
    tokens.forEach((element) {
      if (element.startsWith("ModuleId")) {
        id = BasicElement.getInnerString(element, "[", "]");
      } else if (element.startsWith("ModuleName")) {
        name = BasicElement.getInnerString(element, "[", "]");
      } else if (element.startsWith("ModuleIcon")) {
        icon = BasicElement.getInnerString(element, "[", "]");
      } else if (element.startsWith("ModuleAddresses")) {
        var opts = BasicElement.getOptions(element);
        addresses.add(AddressOwnerAttempt(
            opts['address'], opts['label'], opts['description']));
      } else if (element.startsWith('ModuleReadAccess')) {
        var opts = BasicElement.getOptions(element);
        readAccess
            .add(AddressAccessAttempt(opts['address'], opts['description']));
      } else if (element.startsWith("ModuleFABAction")) {
        fabwidget = BasicElement.getInnerString(element, "[", "]");
      } else if (element.startsWith("ModuleInfo")) {
        moduleInfo = BasicElement.getInnerString(element, "[", "]");
      } else if (element.startsWith("TimeSeries")) {
        var opts = BasicElement.getOptions(element);
        //TODO sollte zeitl. weiter nach hinten verlagert werden,
        // da ggf. noch gar kein Zugriff dafür angefordert wurde

      } else if (element.startsWith("HandleAction")) {
        var opts = BasicElement.getOptions(element);
        actions.add(new ModuleAction(opts["on"], opts["key"], opts["action"]));
      } else if (element.startsWith("ValueLabelPairs")) {
        var opts = BasicElement.getOptions(element);
        print("adiing vlp" + opts["name"]);
        if (accessLayer.getModuleCacheData("vlps") == null) {
          accessLayer.setModuleCacheData("vlps", Map());
        }
        Map vlp = new Map();
        List<String> vals = opts["values"].split(",");
        List<String> labs = opts["labels"].split(",");
        for (var i = 0; i < vals.length; i++) {
          vlp[vals[i]] = labs[i];
        }

        Map vlmap = accessLayer.getModuleCacheData("vlps");
        vlmap[opts["name"]] = vlp;
        accessLayer.setModuleCacheData("vlps", vlmap);
      } else if (element.startsWith("ValueIconPairs")) {
        var opts = BasicElement.getOptions(element);
        print("adiing vip" + opts["name"]);
        if (accessLayer.getModuleCacheData("vips") == null) {
          accessLayer.setModuleCacheData("vips", Map());
        }
        Map vlp = new Map();
        List<String> vals = opts["values"].split("#");
        List<String> labs = opts["icons"].split(",");
        for (var i = 0; i < vals.length; i++) {
          vlp[vals[i]] = labs[i];
        }

        Map vlmap = accessLayer.getModuleCacheData("vips");
        vlmap[opts["name"]] = vlp;
        accessLayer.setModuleCacheData("vips", vlmap);
      }
    });
  }

  List<Widget> getWidget(BuildContext bc) {
    return widg[0];
  }

  Widget getDashWidget(BuildContext bc) {
    if (dashWidg != null) {
      return Wrap(children: dashWidg);
    } else {
      return Container();
    }
  }

  Widget getTab(BuildContext bc, num) {
    return SingleChildScrollView(
        child: ListView(
      padding: const EdgeInsets.all(8),
      children: widg[num],
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    ));
  }

  List<Widget> getTabs(BuildContext bc) {
    List<Widget> tabs = new List<Widget>();

    for (var i = 0; i < widg.length; i++) {
      tabs.add(getTab(bc, i));
    }

    return tabs;
  }

  List<Widget> getTabTitles(BuildContext bc) {
    List<Widget> tabTit = new List<Widget>();

    tabTitles.forEach((element) {
      tabTit.add(Tab(child: Text(element)));
    });

    return tabTit;
  }

  int getTabsNumber() {
    return tabTitles.length;
  }

  Widget getTabBar(BuildContext bc) {
    return TabBar(tabs: getTabTitles(bc));
  }

  Widget getTabBarView(BuildContext bc) {
    return TabBarView(
      children: getTabs(bc),
    );
  }

  @override
  ModuleType getModuleType() {
    return ModuleType.MonkScript;
  }
}
