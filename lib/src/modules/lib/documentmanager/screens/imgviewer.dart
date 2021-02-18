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
import 'package:photo_view/photo_view.dart';


class ImgViewer extends StatefulWidget {
  final Uint8List bytes;
final String title;
  const ImgViewer(this.title,
    this.bytes
   );

  @override
  ImgViewerState createState() => ImgViewerState();
}

class ImgViewerState extends State<ImgViewer> {
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
      body: PhotoView(imageProvider: MemoryImage(widget.bytes),
      ),
    );
  }
}
