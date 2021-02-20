import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

class FullPDFViewer extends StatefulWidget {
  final Uint8List bytes;
  final String title;
  const FullPDFViewer(this.title,
      this.bytes
      );

  @override
  FullPDFViewerState createState() => FullPDFViewerState();
}


class FullPDFViewerState extends State<FullPDFViewer> {


  String dir;

  Future<String> load() async {
    final temppath = (await getApplicationDocumentsDirectory()).path;
    dir = '$temppath/test.pdf';
    final File file = File(dir);
    await file.writeAsBytes(widget.bytes);
    print("done");
    return "done";
  }


  @override
  dispose()
  {
    super.dispose();
    final File file = File(dir);
    file.delete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: load(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          Widget children;
          var alignment = MainAxisAlignment.start;
          if (snapshot.hasData) {
            children = PDFViewerScaffold(
                appBar: AppBar(
                  title: Text("Document"),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ],
                ),
                path: dir);
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
                child: Text('Lade PDF...'),
              )
            ]);
          }
          return children;
        });
  }
}
