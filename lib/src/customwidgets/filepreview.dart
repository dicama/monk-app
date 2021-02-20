import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/editfile.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/pdfviewer.dart';
import 'package:monk/src/modules/modulewidget.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:pdf/pdf.dart';

import 'explorerpreview.dart';
import 'fileexplorerspecial.dart';

enum FileMenu { edit, move, delete }

class _FilePreviewState extends State<FilePreviewWidget> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildFileListTile(context, FileSysFile element) {
    return ListTile(
      leading: Container(
          child: Column(children: [
            Container(
                width: 40,
                height: 4,
                color: widget.element.getParent().classColor),
            Container(
                child: element.isPreviewReady
                    ? Image.memory(
                        element.preview,
                        fit: BoxFit.cover,
                      )
                    : Center(child: Icon(Icons.insert_drive_file)),
                color: Colors.white,
                height: 36,
                width: 40)
          ]),
          width: 40,
          height: 40),
      title: Text(element.name),
      subtitle: Row(
          children: (element.tags
              .map((e) => Container(
                  padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                  child: Badge(
                      animationType: BadgeAnimationType.fade,
                      animationDuration: const Duration(milliseconds: 300),
                      badgeContent: Text(e),
                      shape: BadgeShape.square,
                      borderRadius: BorderRadius.circular(12),
                      badgeColor: Colors.grey.shade300,
                      padding: EdgeInsets.fromLTRB(4, 1, 4, 1))))
              .toList())),
      trailing: IconButton(
          icon: widget.element.isFavorite
              ? Icon(Icons.star, color: Colors.grey.shade700)
              : Icon(Icons.star_border, color: Colors.grey.shade700),
          onPressed: widget.isNumb
              ? null
              : () {
                  widget.element.toggleFavorite();
                }),
      onLongPress: widget.isNumb
          ? null
          : () {
              showFileMenu();
            },
      onTap: widget.isNumb
          ? null
          : () {
              print("pressed");
              ExplorerNotification(element).dispatch(context);
            },
    );
  }

  Widget buildDirListTile(context, FileSysDirectory element) {
    return ListTile(
      leading: Container(
          child: CircleAvatar(
            child: Icon(
              widget.isParent ? Icons.drive_folder_upload : Icons.folder,
              color: Colors.white,
            ),
            backgroundColor: element.classColor,
          ),
          height: 40,
          width: 40),
      title: widget.showFilenames
          ? Text(widget.isParent ? ".." : widget.element.name)
          : Container(),
      subtitle: Row(children: [
        Text(widget.element.getNumberOfChildren().toString() + " Elemente"),
        Row(
            children: (element.tags
                .map((e) => Container(
                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Badge(
                        animationType: BadgeAnimationType.fade,
                        animationDuration: const Duration(milliseconds: 300),
                        badgeContent: Text(e),
                        shape: BadgeShape.square,
                        borderRadius: BorderRadius.circular(12),
                        badgeColor: Colors.grey.shade300,
                        padding: EdgeInsets.fromLTRB(4, 1, 4, 1))))
                .toList()))
      ]),
      trailing: IconButton(
          icon: widget.element.isFavorite
              ? Icon(Icons.star, color: Colors.grey.shade700)
              : Icon(Icons.star_border, color: Colors.grey.shade700),
          onPressed: widget.isNumb
              ? null
              : () {
                  widget.element.toggleFavorite();
                }),
      onLongPress: widget.isNumb
          ? null
          : () {
              showFileMenu();
            },
      onTap: widget.isNumb
          ? null
          : () {
              ExplorerNotification(element).dispatch(context);
            },
    );
  }

  Widget buildFile(context, FileSysFile element) {
    return GestureDetector(
        onTap: () {
          print("Tap");
          ExplorerNotification(element).dispatch(context);
        },
        onLongPress: () {
          showFileMenu();
        },
        child: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border:
                      Border.all(color: Color.fromRGBO(0, 0, 0, 0), width: 0)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Wrap(children: [
                    Container(
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(),
                            height: 20,
                            padding: EdgeInsets.fromLTRB(4, 4, 0, 0),
                            child: Text(
                                widget.element.getParent().name.toUpperCase(),
                                style: Theme.of(context).textTheme.caption),
                          )),
                          Container(
                              padding: EdgeInsets.zero,
                              height: 20,
                              width: 35,
                              child: GestureDetector(
                                child: widget.element.isFavorite
                                    ? Icon(Icons.star,
                                        color: Colors.grey.shade700, size: 20)
                                    : Icon(Icons.star_border,
                                        color: Colors.grey.shade700, size: 20),
                                onTap: () {
                                  widget.element.toggleFavorite();
                                },
                              ))
                        ]),
                        color: Colors.grey[200]),
                    Container(
                        child: Row(children: <Widget>[
                          Expanded(
                            child: Container(height: 5),
                          )
                        ]),
                        color: widget.element.getParent().classColor),
                    Row(children: [
                      Expanded(
                          child: Container(
                              child: element.isPreviewReady
                                  ? Image.memory(
                                      element.preview,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(Icons.insert_drive_file)),
                              color: Colors.white,
                              height: 51))
                    ])
                  ]))),
          Container(
              child: widget.showFilenames
                  ? Text(widget.element.name)
                  : Container())
        ]));
  }

  showFileMenu() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context1) {
          return Container(
            height: 100,
            padding: EdgeInsets.only(top: 12),
            color: Colors.white,
            child: Row(children: [
              Expanded(
                  child: Column(children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
                Text("Bearbeiten")
              ])),
              Expanded(
                  child: Container(
                      child: Column(children: [
                IconButton(
                    icon: Icon(Icons.drive_file_move_outline),
                    onPressed: () {
                      Navigator.pop(context);
                      onMove();
                    }),
                Text("Verschieben")
              ]))),
              Expanded(
                  child: Container(
                      child: Column(children: [
                IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    }),
                Text("Löschen")
              ])))
            ]),
          );
        });
  }

  void onEdit() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditFileScreen(widget.element)));
  }

  void onMove() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          FileSysDirectory chDir = EncryptedFS().getRoot();
          TextEditingController folderController =
              TextEditingController(text: chDir.getFullPath());
          return AlertDialog(
            title: Text('Verschieben'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Bitte wähle einen Order aus'),
              Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    enabled: false,
                    controller: folderController,
                  )),
              Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: FileExplorerSpecWidget(
                    EncryptedFS().getRoot(),
                    onChangeElement: (FileSysElement element) {
                      chDir = element;
                      folderController.text = element.getFullPath();
                    },
                    dirsOnly: true,
                    isHorizontal: true,
                  ))
            ]),
            actions: <Widget>[
              FlatButton(
                  child: Text('Abbrechen'),
                  onPressed: () {
                    // Hier passiert etwas
                    var count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 1;
                    });
                  }),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  widget.element.moveTo(chDir);
                  var count = 0;
                  Navigator.of(context).popUntil((route) {
                    return count++ == 1;
                  });
                },
              ),
            ],
          );
        });
  }

  void onDelete() {
    int count = 0;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (widget.element.checkDeleteable()) {
            return AlertDialog(
              title: Text('Bist Du sicher?'),
              content: Text(
                  'Wills Du die Datei wirklich löschen? (Du kannst sie nicht wiederherstellen)'),
              actions: <Widget>[
                FlatButton(
                    child: Text('Abbrechen'),
                    onPressed: () {
                      // Hier passiert etwas
                      var count = 0;
                      Navigator.pop(context);
                    }),
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    widget.element.delete();
                    print("deleting");
                    var count = 0;
                    Navigator.pop(context);

                  },
                ),
              ],
            );
          } else {
            return AlertDialog(
                title: Text('Ordner nicht leer'),
                content: Text(
                    'Bitte leere erst den Ordner. Dann kannst Du Ihn leeren'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        // Hier passiert etwas
                        var count = 0;
                        Navigator.pop(context);

                      })
                ]);
          }
        });

  }

  Widget buildDir(context, FileSysDirectory element) {
    return GestureDetector(
        onTap: () {
          ExplorerNotification(element).dispatch(context);
        },
        onLongPress: () {
          showFileMenu();
        },
        child: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border:
                      Border.all(color: Color.fromRGBO(0, 0, 0, 0), width: 0)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Wrap(children: [
                    Container(
                        color: Colors.grey.shade200,
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(),
                            height: 20,
                            padding: EdgeInsets.fromLTRB(4, 4, 0, 0),
                            child: Text(
                                widget.element
                                        .getNumberOfChildren()
                                        .toString() +
                                    " ELEMENTE",
                                style: Theme.of(context).textTheme.caption),
                          ))
                        ])),
                    Row(children: [
                      Expanded(
                          child: Container(
                              child: Center(
                                  child: Icon(
                                Icons.folder,
                                color: Colors.white,
                              )),
                              color: element.classColor,
                              height: 56))
                    ])
                  ]))),
          Container(
              child: widget.showFilenames
                  ? Text(widget.isParent ? ".." : widget.element.name)
                  : Container())
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.element.type == FileSysElementType.directory) {
      if (widget.isListElement) {
        return buildDirListTile(context, widget.element);
      } else {
        return buildDir(context, widget.element);
      }
    } else {
      if (widget.isListElement) {
        return buildFileListTile(context, widget.element);
      } else {
        return buildFile(context, widget.element);
      }
    }
  }
}

class FilePreviewWidget extends StatefulWidget {
  final FileSysElement element;
  final bool isParent;
  final bool showFilenames;
  final bool isListElement;
  final bool isNumb;

  FilePreviewWidget(this.element,
      {this.isParent = false,
      this.showFilenames = true,
      this.isListElement = false,
      this.isNumb = false});

  @override
  _FilePreviewState createState() => _FilePreviewState();
}
