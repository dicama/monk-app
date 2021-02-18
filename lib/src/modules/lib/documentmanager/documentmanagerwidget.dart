import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/main.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/customwidgets/explorerpreview.dart';
import 'package:monk/src/customwidgets/fileexplorerspecial.dart';
import 'package:monk/src/customwidgets/filepreview.dart';
import 'package:monk/src/modules/lib/documentmanager/documentmanager.dart';
import 'package:monk/src/modules/lib/documentmanager/fileopenhander.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/savefile.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/takepicture.dart';

import 'package:monk/src/service/encryptedfs.dart';

enum DocumentManagerView { home, favorites }

class _DocumentManagerWidgetState extends State<DocumentManagerWidget> {
  var groupVal = -1;
  var func;
  bool isCompactRecent = false;
  bool isCompactAll = false;
  bool isFavoritesCompact = false;

  DocumentManagerView currentView = DocumentManagerView.home;
  FileSysFile toOpenOnUpdate;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    currentView = widget.initialView;

    // Get a specific camera from the list of available cameras.
  }

  @override
  void didUpdateWidget(covariant DocumentManagerWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    currentView = widget.initialView;
  }

  Widget buildFavorites(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
        height: 70,
        padding: EdgeInsets.all(12),
        child: TypeAheadField(
            hideOnEmpty: true,
            textFieldConfiguration: TextFieldConfiguration(
                autofocus: false,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 18),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(8, 3, 0, 0),
                    hintText: "Suche in Favoriten",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search))),
            suggestionsCallback: (pattern) async {
              if (pattern == "") {
                return [];
              } else {
                return EncryptedFS()
                    .findFiles(pattern.toLowerCase(), isFavorite: true);
              }
            },
            itemBuilder: (context, suggestion) {
              return FilePreviewWidget(
                suggestion,
                isListElement: true,
                isNumb: true,
              );
            },
            onSuggestionSelected: (suggestion) {
              if (suggestion.isDir()) {
                widget.module.mainDirectory = suggestion;
                currentView = DocumentManagerView.home;
              } else {
                widget.module.mainDirectory = suggestion.getParent();
                toOpenOnUpdate = suggestion;
              }
              print(suggestion.toJson());
              updateMainDir();
            }),
      ),
      Row(children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Text("Favoriten".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: Colors.black)))),
        ),
        IconButton(
            icon: isFavoritesCompact
                ? Icon(Icons.view_agenda_outlined)
                : Icon(Icons.list),
            onPressed: () {
              setState(() {
                isFavoritesCompact = !isFavoritesCompact;
              });
            })
      ]),
      Container(
          child: FileExplorerSpecWidget.forFavorites(
        isCompact: isFavoritesCompact,
      ))
    ]));
  }

  updateMainDir() {
    setState(() {
      print(widget.module.mainDirectory.toJson());
    });
    print("updating");
  }

  @override
  Widget buildOverview(BuildContext context1) {
    print("building docman with");
    print(widget.module.mainDirectory.toJson());
    return SingleChildScrollView(
        child: Column(children: [
      Container(
        height: 70,
        padding: EdgeInsets.all(12),
        child: NotificationListener<ExplorerNotification>(
            onNotification: (not) {
              if (not.element.isDir()) {
                print(not.element);
              }
            },
            child: TypeAheadField(
                hideOnEmpty: true,
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontSize: 18),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(8, 3, 0, 0),
                        hintText: "Suche in MONK Ordner",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search))),
                suggestionsCallback: (pattern) async {
                  if (pattern == "") {
                    return [];
                  } else {
                    return EncryptedFS().findFiles(pattern.toLowerCase());
                  }
                },
                itemBuilder: (context, suggestion) {
                  print((suggestion.tags.join(",")));
                  return FilePreviewWidget(suggestion,
                      isListElement: true, isNumb: true);
                },
                onSuggestionSelected:  (suggestion) async  {
                  if (suggestion.isDir()) {
                    widget.module.mainDirectory = suggestion;
                    updateMainDir();

                  } else {
                    widget.module.mainDirectory = suggestion.getParent();
                    await FileOpenHandler.open(suggestion, context1);

                  }
                  print(suggestion.toJson());
                  /*updateMainDir();*/
                })),
      ),
      Row(children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Text("Zuletzt hochgeladen".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: Colors.black)))),
        ),
        IconButton(
            icon: isCompactRecent
                ? Icon(Icons.view_agenda_outlined)
                : Icon(Icons.list),
            onPressed: () {
              setState(() {
                isCompactRecent = !isCompactRecent;
              });
            })
      ]),
      FileExplorerSpecWidget.forRecentlyAdded(
        7,
        isHorizontal: true,
        isCompact: isCompactRecent,
      ),
      Row(children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Text(widget.module.mainDirectory.getFullPath(),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: Colors.black))),
              alignment: Alignment.centerLeft),
        ),
        IconButton(
            icon: isCompactAll
                ? Icon(Icons.view_agenda_outlined)
                : Icon(Icons.list),
            onPressed: () {
              setState(() {
                isCompactAll = !isCompactAll;
              });
            })
      ]),
      Container(
          child: FileExplorerSpecWidget(
        widget.module.mainDirectory,
        isCompact: isCompactAll,
        onChangeElement: (ele) {
          setState(() {
            widget.module.mainDirectory = ele;
          });
        },
      ))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    /*widget.module.getFABAction(context,);*/
    return MonkScaffold(
        title: widget.module.name,
        body: widget.module.currentView == DocumentManagerView.home
            ? buildOverview(context)
            : buildFavorites(context),
        bottomNavigationBar: widget.module.getBottomNavBar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: widget.module.getFABAction(context, () {
            setState(() {
              if (widget.module.currentView == DocumentManagerView.home) {
                widget.module.mainDirectory = EncryptedFS().getRoot();
              }
            });
          }),
          tooltip: 'Increment',
          backgroundColor: Theme.of(context).buttonColor,
          child: Icon(Icons.add),
        ));
  }
}

class DocumentManagerWidget extends StatefulWidget {
  final DocumentManagerView initialView;
  final DocumentManagerModule module;

  const DocumentManagerWidget(this.initialView, this.module);

  @override
  _DocumentManagerWidgetState createState() => _DocumentManagerWidgetState();
}
