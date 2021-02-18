import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/models/DrawerModel.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/service/moduleloader.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:monk/tools.dart';
import 'package:provider/provider.dart';

import 'basicmodule.dart';
import 'modulewidget.dart';

class ModuleDashboardWidget extends StatelessWidget {
  BasicModule currentModule;
  bool isCompact;

  ModuleDashboardWidget(this.currentModule, {this.isCompact = false})
      : super(key: Key(currentModule.name));

  @override
  Widget build(BuildContext context) {
    Stopwatch stopwatch = new Stopwatch()..start();

    String dateString = "";
    bool hasData = true;
    if (currentModule.hasFABAction()) {
      dateString = AccessLayer().getModuleDataString(
          currentModule.id, "last_entry", defaultValue: "Nicht vorhanden");
      if (dateString != "Nicht vorhanden") {
        dateString = convertDateTimeToRelative(DateTime.parse(dateString));
      }
    }

    if (dateString == "Nicht vorhanden") {
      hasData = false;
    }

    var retVal = NotificationListener<BasicElementNotification>(
        key: Key(currentModule.name),
        onNotification: (notification) {
          currentModule.handleNotification(notification, context);
          return true;
        },
        child: GestureDetector(
            onTap: () {
              Provider.of<DrawerModel>(context, listen: false).selectedItem =
                  currentModule.name;
              Provider.of<DrawerModel>(context, listen: false).selectedModule =
                  currentModule.name;
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ModuleWidget(currentModule)))
                  .then((noparam) {
                UpdateNotification().dispatch(context);
              });
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.7),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2), // changes position of shadow
                          ),
                        ],
                        border: Border.all(
                            color: Color.fromRGBO(226, 224, 228, 1), width: 0)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Wrap(children: [
                          Container(
                              child: Row(children: <Widget>[
                                Container(
                                    child: currentModule.getModuleIcon(
                                        size: 25,
                                        color: Theme.of(context).accentColor),
                                    // DONE
                                    padding: EdgeInsets.fromLTRB(12, 0, 8, 0)),
                                Expanded(
                                    child: Container(
                                  decoration: BoxDecoration(),
                                  height: 40,
                                  padding: EdgeInsets.fromLTRB(8, 9, 0, 0),
                                  child: Text(currentModule.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1)),
                                )),
                                Container(
                                    child: IconButton(
                                  icon: Icon(Icons.more_horiz),
                                  onPressed: () {
                                    showModuleMenu(context);
                                  },
                                ))
                              ]),
                              color: Theme.of(context).primaryColorDark),
                          currentModule.hasFABAction()
                              ? Container(
                                  child: Row(children: <Widget>[
                                    Container(
                                        child: Text(
                                            "LETZTER EINTRAG: " ,
                                            style: Theme.of(context)
                                                .textTheme
                                                .overline),
                                        padding:
                                            EdgeInsets.fromLTRB(8, 0, 0, 0)),
                                    Expanded(
                                        child: Container(
                                      height: 40,
                                      padding: EdgeInsets.fromLTRB(4, 13, 0, 0),
                                      child: Text(dateString.toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline),
                                    )),
                                    GestureDetector(
                                        child: Container(
                                          height: 40,
                                          child: Icon(
                                              MdiIcons.plusCircleOutline,
                                              size: 30,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.6)),
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 11, 0),
                                        ),
                                        onTap: currentModule
                                            .getFABAction(context, () {
                                          UpdateNotification()
                                              .dispatch(context);
                                        }) // if module has a FAB action make it available here
                                        )
                                  ]),
                                  color: Colors.white)
                              : Container(),
                          (isCompact || !hasData)
                              ? Container()
                              : Container(
                                  child: currentModule.getDashWidget(context),
                                  color: Colors.white)
                        ]))))));
    print(
        'Dashboard for ${currentModule.name} build took ${stopwatch.elapsed}');
    return retVal;
  }

  void showModuleMenu(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: EdgeInsets.fromLTRB(24, 24, 8, 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("MODUL: " + currentModule.name.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .merge(TextStyle(color: Colors.black))))),
              Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.verified_outlined),
                          label: Expanded(child: Text("Version 0.1"))))),
              Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.info_outline),
                          label: Expanded(child: Text("Information"))))),
              Container(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: FlatButton.icon(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text(
                                        'MONK wird das Modul ${currentModule.name} deinstallieren'),
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
                                        child: Text('FORTFAHREN'),
                                        onPressed: () {
                                          var count = 0;
                                          if (currentModule.getModuleType() ==
                                              ModuleType.MonkScript) {
                                            Module curMod = currentModule;
                                            ModuleLoader()
                                                .removeModule(curMod.filename);
                                            Navigator.popUntil(context,
                                                (route) {
                                              return count++ == 1;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: Icon(Icons.delete_outline),
                          label: Expanded(child: Text("Deinstallieren"))))),
            ]),
          );
        });
  }
}
