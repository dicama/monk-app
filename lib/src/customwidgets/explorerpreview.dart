import 'package:flutter/material.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/pdfviewer.dart';
import 'package:monk/src/service/encryptedfs.dart';

typedef FileSysElementVoid = void Function(FileSysElement);

class ExplorerNotification extends Notification {
  FileSysElement element;

  ExplorerNotification(this.element);
}

class _ExplorerPreviewState extends State<ExplorerPreviewWidget> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildDirectory(BuildContext context, FileSysDirectory dir) {
    return GestureDetector(
        onTap: () {
          ExplorerNotification(dir).dispatch(context);
        },
        child: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border:
                  Border.all(color: Color.fromRGBO(0, 0, 0, 0), width: 0)),
              child: Wrap(children: [
                !dir.isPreviewReady
                    ? Row(children: [
                  Expanded(
                      child: Container(
                          child: Icon(Icons.folder
                              , color: dir.classColor),
                           height: 51))
                ])
                    : Row(children: [
                  Expanded(
                      child: Container(
                          child: Image.memory(
                            dir.preview,
                            fit: BoxFit.contain,
                          ),
                          color: Colors.white,
                          height: 51))
                ])
              ])),
          Container(child: Text(widget.isParent ? ".." : dir.name))
        ]));
  }

  buildFile(BuildContext context, FileSysFile file) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PDFViewer(file.name,
                        EncryptedFS().loadEncryptedFile(file.uid))),
          );
        }
        ,
        child: Column(children: [
        Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border:
            Border.all(color: Color.fromRGBO(0, 0, 0, 0), width: 0)),
        child: Wrap(children: [
          !file.isPreviewReady
              ? Row(children: [
            Expanded(
                child: Container(
                    child: Icon(Icons.insert_drive_file),
                    color: Colors.white,
                    height: 51))
          ])
              : Row(children: [
            Expanded(
                child: Container(
                    child: Image.memory(
                      file.preview,
                      fit: BoxFit.contain,
                    ),
                    color: Colors.white,
                    height: 51))
          ])
        ])),
    Container(child: Text(file.name)),
    ]
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.element.type == FileSysElementType.directory) {
      return buildDirectory(context, widget.element);
    } else {
      return buildFile(context, widget.element);
    }
  }
}

class ExplorerPreviewWidget extends StatefulWidget {
  final FileSysElement element;
  final bool isParent;


  ExplorerPreviewWidget(this.element, {this.isParent = false});

  @override
  _ExplorerPreviewState createState() => _ExplorerPreviewState();
}
