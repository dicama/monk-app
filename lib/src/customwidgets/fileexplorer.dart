import 'package:flutter/material.dart';
import 'package:monk/src/service/encryptedfs.dart';

import 'explorerpreview.dart';

class _FileExplorerState extends State<FileExplorerWidget> {
  FileSysDirectory fsDir;

  @override
  void initState() {
    super.initState();
    fsDir = widget.initalDir;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> files;

    if (widget.dirsOnly) {
      files = fsDir
          .getChildrenDirs()
          .map((e) => Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              width: 120,
              child: ExplorerPreviewWidget(e)))
          .toList();
    } else {
      files = fsDir
          .getChildren()
          .map((e) => Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              width: 120,
              child: ExplorerPreviewWidget(e)))
          .toList();
    }

    if (fsDir.getParent() != null) {
      files.insert(
          0,
          Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              width: 120,
              child: ExplorerPreviewWidget(fsDir.getParent(), isParent: true)));
    }

    return NotificationListener<ExplorerNotification>(
        onNotification: (not) {
          fsDir = not.element;
          if (widget.onChangeElement != null) {
            widget.onChangeElement(not.element);
          }
          setState(() {});
          return true;
        },
        child: Container(
            height: 140.0,
            child:
                ListView(scrollDirection: Axis.horizontal, children: files)));
  }
}

class FileExplorerWidget extends StatefulWidget {
  FileSysDirectory initalDir;
  bool dirsOnly = false;
  FileSysElementVoid onChangeElement;

  FileExplorerWidget(this.initalDir,
      {this.onChangeElement, this.dirsOnly = false});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}
