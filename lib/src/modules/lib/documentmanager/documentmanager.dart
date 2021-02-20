import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monk/src/customwidgets/fileexplorerspecial.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/savefile.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/takepicture.dart';

import 'package:monk/src/modules/lib/documentmanager/documentmanagerwidget.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

import '../../basicmodule.dart';

class DocumentManagerModule extends BasicModule {
  var firstCamera;
  static String documentManagerId = "document_manager";
  var cameras;
  var currentView = DocumentManagerView.home;
  UpdateVoidFunction update;
  FileSysDirectory mainDirectory;

  DocumentManagerModule() {
    name = "Dokumentenmanager";
    icon = "fileAccountOutline";
    id = DocumentManagerModule.documentManagerId;
    mainDirectory = EncryptedFS().getRoot();
    moduleInfo =
        "Mit dem Dokumentenmanager kannst Du Deine Dokumente und Schriftverkehr rund um den Krebs übersichtlich organisieren. So hast Du alle Dokumente sofort zur Hand, wenn Du sie benötigst.";
    AccessLayer().register(
        id, "filesystem", "Verschluesseltes Dateisystem", "Blabalbalabl");
    AccessLayer().register(
        id, "filesystemver", "Version des Enc Dateisystems", "Blabalbalabl");
  }

  @override
  bottomNavBarTap(index, BuildContext bc) {
    switch (index) {
      case 0:
        currentView = DocumentManagerView.home;
        break;

      case 1:
        showModuleInfo(bc);
        break;

      case 2:
        currentView = DocumentManagerView.favorites;
        break;
    }
    print("buttonnavbartap");
    if (update != null) {
      update();
    }
  }

  Widget getBottomNavBar(context) {
    return BottomNavigationBar(
      onTap: (index) => this.bottomNavBarTap(index, context),
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: this.getModuleIcon(),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'Info',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Favoriten',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_vert),
          label: 'Mehr',
        ),
      ],
      selectedItemColor: Theme.of(context).accentColor,
    );
  }

  @override
  Widget buildModule(BuildContext context, UpdateVoidFunction callbackVoid) {
    return DocumentManagerWidget(currentView, this);
  }

/*
  @override
  Function getFABAction(BuildContext context, UpdateVoidFunction callbackVoid) {
    update = callbackVoid;

    return () {
      return showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.only(top:12),
              height: 100,
              color: Colors.white,
              child: Row(children: [
                Expanded(
                  child: Column(children: [
                    Container(
                      child: IconButton(
                          onPressed: () {
                            TextEditingController folderController;
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    //this right here
                                    content:
                                        TextField(controller: folderController),
                                    actions: [
                                      FlatButton(
                                          child: Text("Abbrechen"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      FlatButton(
                                          child: Text("Erstellen"),
                                          onPressed: () {})
                                    ],
                                  );
                                });
                          },
                          iconSize: 36,
                          icon: Icon(Icons.create_new_folder_rounded)),
                    ),
                    Text('Neuer Ordner', textAlign: TextAlign.center)
                  ]),
                ),
                Expanded(
                    child: Column(children: [
                  Container(
                      child: IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, __, ___) =>
                                  TakePictureScreen(first: true),
                              transitionDuration: Duration(seconds: 0)));
                    },
                  )),
                  Text('Scannen', textAlign: TextAlign.center)
                ])),
                Expanded(
                    child: Column(children: [
                  Container(
                      child: IconButton(
                          iconSize: 36,
                          icon: Icon(Icons.upload_rounded),
                          onPressed: () async {
                            FilePickerResult result =
                                await FilePicker.platform.pickFiles();

                            if (result != null) {
                              File file = File(result.files.single.path);
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (context, __, ___) =>
                                          SaveFileScreen.forFile(file),
                                      transitionDuration:
                                          Duration(seconds: 0)));
                            } else {
                              Navigator.pop(context);
                              // User canceled the picker
                            }
                          })),
                  Text('Hochladen', textAlign: TextAlign.center)
                ]))
              ]),
            );
          }).then((asd) {
        callbackVoid();
      });
    };
  }*/

  @override
  Function getFABAction(BuildContext context, UpdateVoidFunction callbackVoid) {
    update = callbackVoid;

    return () {
      return showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context2) {
            return Container(
              padding: EdgeInsets.only(top: 12),
              height: 100,
              color: Colors.white,
              child: Row(children: [
                Expanded(
                  child: Column(children: [
                    Container(
                        child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        TextEditingController folderController =
                            TextEditingController(text: "Neuer Ordner");
                        showDialog(
                            context: context,
                            builder: (BuildContext context1) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                //this right here
                                content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Neuen Ordner erstellen",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                      TextField(controller: folderController)
                                    ]),
                                actions: [
                                  FlatButton(
                                      child: Text("Abbrechen"),
                                      onPressed: () {
                                        Navigator.of(context1).pop();
                                      }),
                                  FlatButton(
                                    child: Text("Erstellen"),
                                    onPressed: () {
                                      if (folderController.text.length < 1 ||
                                          mainDirectory.getChildDirWithName(
                                                  folderController.text) !=
                                              null) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context1) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                content: Text(
                                                    "Ordner mit diesem Namen besteht bereits oder Ordnername nicht zulässig."),
                                                actions: [
                                                  FlatButton(
                                                      child: Text("Ok"),
                                                      onPressed: () {
                                                        Navigator.of(context1)
                                                            .pop();
                                                      })
                                                ],
                                              );
                                            });
                                      } else {
                                        mainDirectory.addDir(FileSysDirectory(
                                            DateTime.now(),
                                            folderController.text,
                                            mainDirectory));
                                      }
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      iconSize: 36,
                      icon: Icon(Icons.create_new_folder_rounded),
                    )),
                    Expanded(
                        child: Text('Neuen Ordner anlegen',
                            textAlign: TextAlign.center))
                  ]),
                ),
                Expanded(
                    child: Column(children: [
                  Container(
                      child: IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, __, ___) =>
                                  TakePictureScreen(first: true),
                              transitionDuration: Duration(seconds: 0)));
                    },
                  )),
                  Expanded(
                      child: Text('Neues Foto erstellen',
                          textAlign: TextAlign.center))
                ])),
                Expanded(
                    child: Column(children: [
                  Container(
                      child: IconButton(
                          iconSize: 36,
                          icon: Icon(Icons.upload_rounded),
                          onPressed: () async {
                            Navigator.of(context2).pop();

                            showDialog(
                                context: context,
                                builder: (BuildContext context1) {
                                  return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      //this right here
                                      content: Row(mainAxisSize: MainAxisSize.min,children: [
                                        Expanded(child:FlatButton(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(Icons
                                                    .insert_drive_file_outlined),
                                                Text("Dateien"),
                                              ],
                                            ),
                                            onPressed: () async {
                                              FilePickerResult result =
                                                  await FilePicker.platform
                                                      .pickFiles();

                                              if (result != null) {
                                                File file = File(
                                                    result.files.single.path);
                                                Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                __, ___) =>
                                                            SaveFileScreen
                                                                .forFile(file),
                                                        transitionDuration:
                                                            Duration(
                                                                seconds: 0)));
                                                Navigator.of(context1).pop();
                                              } else {
                                                // User canceled the picker
                                              }
                                            })),
                                  Expanded(child:FlatButton(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(Icons.photo_library),
                                              Text("Gallerie"),
                                            ],
                                          ),
                                          onPressed: () async {
                                            final picker = ImagePicker();
                                            final result =
                                                await picker.getImage(
                                                    source:
                                                        ImageSource.gallery);

                                            if (result != null) {
                                              File file = File(result.path);
                                              print(result.path);
                                              Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                      pageBuilder: (context, __,
                                                              ___) =>
                                                          SaveFileScreen
                                                              .forFile(file),
                                                      transitionDuration:
                                                          Duration(
                                                              seconds: 0)));
                                              Navigator.of(context1).pop();
                                            } else {
                                              // User canceled the picker
                                            }
                                          },
                                        ))
                                      ]));
                                });
                          })),
                  Expanded(
                      child:
                          Text('Datei hinzufügen', textAlign: TextAlign.center))
                ]))
              ]),
            );
          }).then((noparam) {
        update();
      });
    };
  }

  @override
  ModuleType getModuleType() {
    return ModuleType.DartClass;
  }

  bool hasFABAction() {
    return true;
  }

  @override
  handleNotification(BasicElementNotification ben, BuildContext con) {}

  @override
  getDashWidget(BuildContext context) {
    return Container(
        height: 110.0,
        child: FileExplorerSpecWidget.forRecentlyAdded(
          7,
          isHorizontal: true,
          height: 135.0,
          showFilenames: false,
        ));
  }
}
