import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/reviewpicture.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';


class PDFViewer extends StatefulWidget {
  final Uint8List bytes;
final String title;
  const PDFViewer(this.title,
    this.bytes
   );

  @override
  PDFViewerState createState() => PDFViewerState();
}

class PDFViewerState extends State<PDFViewer> {
int pages;
bool isReady = false;
bool isSampleDoc = false;
final Completer<PDFViewController> _controller =
Completer<PDFViewController>();

  @override
  void initState() {

    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: PDFView(
        pdfData: widget.bytes,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: false,
        onRender: (_pages) {
          print("trying to setting state");

          setState(() {
            pages = _pages;
            isReady = true;
            print("setting state");
          });
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _controller.complete(pdfViewController);
        },
        onPageChanged: (int page, int total) {
          print('page change: $page/$total');
        },
      ),
    );
  }
}
