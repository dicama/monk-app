import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monk/src/customwidgets/filepreview.dart';
import 'package:monk/src/modules/lib/documentmanager/fileopenhander.dart';
import 'package:monk/src/service/encryptedfs.dart';

import 'explorerpreview.dart';

class _FileExplorerSpecState extends State<FileExplorerSpecWidget> {
  FileSysDirectory fsDir;
  StreamSubscription strsub;

  @override
  void initState() {
    super.initState();
    fsDir = widget.initalDir;
    print("initaldir");
    strsub = EncryptedFS().saveStream.stream.listen((event) {
      print("updating fs outside");
      setState(() {
        print("updating fs");
      });
    });
  }


  @override
  void didUpdateWidget(covariant FileExplorerSpecWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    fsDir = widget.initalDir;
  }

  @override
  void dispose() {
    super.dispose();
    strsub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> files;
    List<FileSysElement> tempFiles; // temporary files selected in this view

    if (widget.initalDir == null) {
      if (widget.isFavorites) {
        tempFiles = EncryptedFS().getFavorites(); //get favorites
      } else {
        tempFiles =
            EncryptedFS().getRecentlyAddedFiles(widget.numberOfRecentFiles);
      }
    } else {
      if (widget.dirsOnly) {
        tempFiles = fsDir.getChildrenDirs();
      } else {
        tempFiles = fsDir.getChildren();
      }
    }

    if (widget.isCompact) {
      files = tempFiles
          .map((e) => FilePreviewWidget(e,
              showFilenames: widget.showFilenames, isListElement: true))
          .toList();
      if (widget.initalDir != null) {
        if (fsDir.getParent() != null) {
          files.insert(
              0,
              FilePreviewWidget(
                fsDir.getParent(),
                isParent: true,
                showFilenames: widget.showFilenames,
                isListElement: true,
              ));
        }
      }
    } else {
      files = tempFiles
          .map((e) => Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              width: MediaQuery.of(context).size.width / 3,
              child: FilePreviewWidget(
                e,
                showFilenames: widget.showFilenames,
              )))
          .toList();

      if (widget.initalDir != null) {
        if (fsDir.getParent() != null && !(fsDir == widget.initalDir && widget.limitToInitialDir)) {
          files.insert(
              0,
              Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  width: MediaQuery.of(context).size.width / 3,
                  child: FilePreviewWidget(
                    fsDir.getParent(),
                    isParent: true,
                    showFilenames: widget.showFilenames,
                  )));
        }
      }
    }

    if (widget.isCompact) {
      return NotificationListener<ExplorerNotification>(
          onNotification: (not)  {
            if (not.element.isFile()) {
              FileOpenHandler.open(not.element, context);
            } else {
              fsDir = not.element;
            }
            if (widget.onChangeElement != null) {
              widget.onChangeElement(not.element);
            }
            setState(() {});
            return true;
          },
          child: ListView(
            children: files,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ));
    } else {
      return NotificationListener<ExplorerNotification>(
          onNotification: (not) {
            if (not.element.isFile()) {
              FileOpenHandler.open(not.element, context);
            } else {
              if(!widget.isFavorites) {
                fsDir = not.element;
              }
            }
            if (widget.onChangeElement != null) {
              widget.onChangeElement(not.element);
            }
            setState((){});
            return true;
          },
          child: widget.isHorizontal
              ? Container(
                  height: widget.height,
                  child:
                  ListView(
                      scrollDirection: Axis.horizontal, children: files))
              : GridView.count(children: files, crossAxisCount: 3, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),));
    }

  }
}

class FileExplorerSpecWidget extends StatefulWidget {
  final FileSysDirectory initalDir;
  final int numberOfRecentFiles;
  final bool dirsOnly;
  final bool isHorizontal;
  final bool showFilenames;
  final bool isFavorites;
  final bool limitToInitialDir;
  final bool isCompact;
  final double height;
  final FileSysElementVoid onChangeElement;

  FileExplorerSpecWidget(this.initalDir,
      {this.onChangeElement,
      this.showFilenames = true,
      this.dirsOnly = false,
      this.isHorizontal = false,
      this.height = 140.0,
      this.isCompact = false, this.limitToInitialDir = false})
      : numberOfRecentFiles = 0,
        isFavorites = false;

  FileExplorerSpecWidget.forRecentlyAdded(this.numberOfRecentFiles,
      {this.onChangeElement,
      this.showFilenames = true,
      this.dirsOnly = false,
      this.isHorizontal = false,
      this.height = 140.0,
      this.isCompact = false,this.limitToInitialDir = false})
      : initalDir = null,
        isFavorites = false;

  FileExplorerSpecWidget.forFavorites(
      {this.onChangeElement,
      this.showFilenames = true,
      this.dirsOnly = false,
      this.isHorizontal = false,
      this.height = 140.0,
      this.isCompact = false,this.limitToInitialDir = false})
      : initalDir = null,
        numberOfRecentFiles = 0,
        isFavorites = true;

  @override
  _FileExplorerSpecState createState() => _FileExplorerSpecState();
}
