import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/moduleloader.dart';
import 'package:monk/src/service/accesslayer.dart';

class _AppStoreState extends State<AppStore> {
  Future<http.Response> fetchList() {
    return http.get(Uri.parse('https://api.github.com/repos/dicama/monk-modules/contents/modules?ref=main'));
  }

  Future<http.Response> fetchModule(var url) {
    return http.get(url);
  }

  Future<Widget> getModules(context) async {
    await ModuleLoader().syncAppStore();
    var ret = new List<Widget>();
    List<dynamic> tempL = List();
    ModuleLoader().appStoreIndex.forEach((element) {
      tempL.add(element);
    });
    tempL.sort((a, b) {
      var vala = -1;
      var valb = -1;
      if (ModuleLoader().appStoreInstalled.contains(a.fileName)) {
        vala = 0;
      }
      if (ModuleLoader().appStoreInstalled.contains(b.fileName)) {
        valb = 0;
      }
      return vala - valb;
    });

    /*tempL.forEach((element) {
      if (true ==
          true */ /*!ModuleLoader().appStoreInstalled.contains(element.fileName)*/ /*) {
        final String name = Module.getModuleName(
            ModuleLoader().appStoreCache[element.fileName]);
        final String id = Module.getModuleId(
            ModuleLoader().appStoreCache[element.fileName]);
        final String infoText = Module.getModuleInfo(
            ModuleLoader().appStoreCache[element.fileName]);
        final String iconName = Module.getModuleIconQuick(
            ModuleLoader().appStoreCache[element.fileName]);
        final String version = Module.getModuleVersionQuick(
            ModuleLoader().appStoreCache[element.fileName]);
        var icon;
        if (element.iconUrl != null) {
          icon = SvgPicture.network(element.iconUrl, height: 40, width: 40);
        } else {
          icon = Icon(MdiIcons.fromString(iconName), size: 40);
        }
        ret.add(GestureDetector(
          child: Container(
              width: 196,
              height: 200,
              padding: EdgeInsets.all(10),
              child: Card(
                  elevation: 15,
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(name,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  overflow: TextOverflow.ellipsis),
                            )),
                        ModuleLoader()
                                .appStoreInstalled
                                .contains(element.fileName)
                            ? Container(
                                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                child: Row(children: [
                                  Icon(Icons.verified,
                                      size: 14,
                                      color: Color.fromRGBO(0, 139, 48, 1)),
                                  Text(" INSTALLIERT",
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .merge(TextStyle(
                                              color: Color.fromRGBO(
                                                  0, 139, 48, 1))))
                                ]))
                            : Container(
                                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                child: Row(children: [
                                  Icon(Icons.verified,
                                      size: 14,
                                      color: Color.fromRGBO(0, 139, 48, 1)),
                                  Text(" VERFÜGBAR",
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .merge(TextStyle(
                                              color: Color.fromRGBO(
                                                  0, 139, 48, 1)))),
                                ])),
                        Container(
                            padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: Center(
                              child: icon,
                            )),
                        infoText != null
                            ? Expanded(
                                child: ListView(shrinkWrap: true, children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Text(infoText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                    ))
                              ]))
                            : Container()
                      ])))),
          onTap: () {
            showModuleMenu(context, name, element.fileName, id, version);
          },
        ));
      }
    });*/

    int count = 0;
    var themeData = Theme.of(context);
    List<Widget> childs = new List();
    tempL.forEach((element) {
      final String name =
          Module.getModuleName(ModuleLoader().appStoreCache[element.fileName]);
      final String id =
          Module.getModuleId(ModuleLoader().appStoreCache[element.fileName]);
      final String infoText =
          Module.getModuleInfo(ModuleLoader().appStoreCache[element.fileName]);
      final String iconName = Module.getModuleIconQuick(
          ModuleLoader().appStoreCache[element.fileName]);
      final String version = Module.getModuleVersionQuick(
          ModuleLoader().appStoreCache[element.fileName]);
      bool installed =
          ModuleLoader().appStoreInstalled.contains(element.fileName);
      var icon;
      if (element.iconUrl != null) {
        icon = SvgPicture.network(element.iconUrl, height: 40, width: 40);
      } else {
        icon = Icon(MdiIcons.fromString(iconName), size: 40);
      }
      childs.add(ListTile(
        key: Key(id),
        leading: icon,
        title:
            Column(children: [
              Row(children: [Text(name, textAlign: TextAlign.left)]),
              installed
                  ? Row(children: [
                      Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(Icons.verified,
                          size: 14, color: Color.fromRGBO(0, 139, 48, 1))),
                      Text("Installiert", style: themeData.textTheme.button)
                    ])
                  : Row(children: [Text("Verfügbar", style: themeData.textTheme.button)]),
        ]),
        subtitle: Text(infoText == null ? "" : infoText),
        onTap: () {
          showModuleMenu(context, name, element.fileName, id, version);
        },
      ));
      childs.add(Divider());
    });
    return ListView(
      shrinkWrap: true,
      children: childs,
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  void showModuleMenu(BuildContext context, String name, String file, String id,
      String version) {
    String versionText = "";
    if (version == null) {
      versionText = "";
    } else {
      versionText = " (" + version + ")";
    }

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          var themeData = Theme.of(context);

          return Container(
            color: Colors.white,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: EdgeInsets.fromLTRB(24, 24, 8, 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("MODUL: " + name.toUpperCase() + versionText,
                          style: themeData.textTheme.caption
                              .merge(TextStyle(color: Colors.black))))),
              Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.info_outline),
                          label: Expanded(child: Text("Information"))))),
              ModuleLoader().appStoreInstalled.contains(file)
                  ? Container(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: FlatButton.icon(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('${name}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        content: Text(
                                            'MONK wird das Modul ${name} deinstallieren\n\nAchtung: Dabei werden auch die damit verbunden Datensätze unwideruflich gelöscht\n\nSolltest Du die Daten für eine zukünftige Nutzung behalten wollen, kannst du dies vor der Deinstallation bestätigen.'),
                                        actions: <Widget>[
                                          FlatButton(
                                              child: Text('ABBRECHEN'),
                                              onPressed: () {
                                                var count = 0;
                                                Navigator.popUntil(context,
                                                    (route) {
                                                  return count++ == 1;
                                                });
                                              }),
                                          FlatButton(
                                            child: Text(
                                                'MIT DATENSICHERUNG DEINSTALLIEREN'),
                                            onPressed: () {
                                              var count = 0;

                                              ModuleLoader().removeModule(file);
                                              setState(() {});
                                              Navigator.popUntil(context,
                                                  (route) {
                                                return count++ == 1;
                                              });
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: themeData.buttonColor,
                                                shadowColor: themeData
                                                    .secondaryHeaderColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0))),
                                            child: Text(
                                                'VOLLSTÄNDIG DEINSTALLIEREN',
                                                style:
                                                    themeData.textTheme.button),
                                            onPressed: () {
                                              var count = 0;
                                              AccessLayer()
                                                  .deleteModuleData(id);
                                              ModuleLoader().removeModule(file);
                                              setState(() {});
                                              Navigator.popUntil(context,
                                                  (route) {
                                                return count++ == 1;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    });
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.delete_outline),
                              label: Expanded(child: Text("Deinstallieren")))))
                  : Container(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: FlatButton.icon(
                              onPressed: () {
                                ModuleLoader().addModule(file);
                                setState(() {});
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.add_circle),
                              label: Expanded(child: Text("Installieren"))))),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MonkScaffold(
      title: "Store",
      body: FutureBuilder<Widget>(
          future: getModules(context),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            Widget children;
            var alignment = MainAxisAlignment.start;
            if (snapshot.hasData) {
              children = snapshot.data;
            } else if (snapshot.hasError) {
              children = Wrap(children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ]);
            } else {
              alignment = MainAxisAlignment.center;
              children = Wrap(children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 30,
                  height: 30,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Lade Module...'),
                )
              ]);
            }
            return children;
/*
            return SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              */ /*Container(
                  padding: EdgeInsets.all(8),
                  child: TypeAheadField(
                      hideOnEmpty: true,
                      textFieldConfiguration: TextFieldConfiguration(
                          autofocus: false,
                          style: Theme.of(context).textTheme.bodyText1
                              .copyWith(fontSize: 18),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(8, 3, 0, 0),
                              hintText: "Suche im AppStore",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.search))),
                      suggestionsCallback: (pattern) async {
                        if (pattern == "") {
                          return [];
                        } else {}
                      },
                      itemBuilder: (context, suggestion) {
                        print((suggestion.tags.join(",")));
                      },
                      onSuggestionSelected: (suggestion) {})),*/ /*
              Wrap(
                children: children,
              )
            ]));*/
          }),
    );
  }
}

class AppStore extends StatefulWidget {
  AppStore();

  @override
  _AppStoreState createState() => _AppStoreState();
}
