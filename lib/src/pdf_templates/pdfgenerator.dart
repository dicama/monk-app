import 'dart:typed_data';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as im;
import 'package:intl/intl.dart';
import 'package:monk/src/pdf_templates/elements/sizedboxpdfelement.dart';
import 'package:monk/src/pdf_templates/elements/timeseriestotablepdfelement.dart';
import 'package:monk/src/pdf_templates/elements/textpdfelement.dart';
import 'package:monk/src/pdf_templates/elements/timeseriesbarchartpdfelement.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'elements/basicpdfelement.dart';
import 'elements/timeserieschartpdfelement.dart';

typedef ReportCallback = List<pw.Widget> Function(pw.Context context);

class PDFGenerator {
  static List<BasicPDFElement> registered = [
    SizedBoxPDFElement(),
    TimesSeriesBarChartPDFElement(),
    TimesSeriesChartPDFElement(),
    TextPDFElement(),
    TimeSeriesToTablePDFElement()

  ];

  static List<pw.Widget> parseString(
      String input, pw.Context context, String moduleIdentifier) {
    List<String> tokens = input.split("\n");
    List<pw.Widget> wigs = List<pw.Widget>();
    tokens.forEach((token) {
      print("parsing " + token);
      for(BasicPDFElement element in registered) {
        print(element.key);
        if (token.startsWith(element.key)) {
          print("in there " + element.key);
          wigs.addAll(element.parseScript(token, context, moduleIdentifier));
          break;
        }
      }
    });

    return wigs;
  }

  static Future<Uint8List> generatePDF(
      String input, String moduleIdentifier) async {

    final document = pw.Document();


    ByteData bytesLogo = await rootBundle.load('assets/icons/monkicon.png');
    final image = pw.MemoryImage(
      bytesLogo.buffer.asUint8List(),
    );

    document.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: pw.Font.ttf(
              await rootBundle.load('assets/fonts/OpenSans-Regular.ttf')),
          bold: pw.Font.ttf(
              await rootBundle.load('assets/fonts/OpenSans-Bold.ttf')),
        ),
        build: (context) {
          List<pw.Widget> widgs = List();
          widgs.add(pw.Row(children: [ pw.Expanded(child: pw.Column(children: [pw.Container(alignment: pw.Alignment.centerLeft, child: pw.Text("MONK Report", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold))),pw.Container(alignment: pw.Alignment.centerLeft, child: pw.Text(DateFormat().addPattern("dd.MM.yy").format(DateTime.now()), style: pw.TextStyle(fontSize: 20)))])),pw.Image(image,width: 80)]));
          widgs.addAll(
              PDFGenerator.parseString(input, context, moduleIdentifier));
          return widgs;
        }));

    return document.save();
  }

  static Future<Uint8List> generatePDFReportFromList(
      ReportCallback repCall) async {

    final document = pw.Document();


    ByteData bytesLogo = await rootBundle.load('assets/icons/monkicon.png');
    final image = pw.MemoryImage(
      bytesLogo.buffer.asUint8List(),
    );

    document.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: pw.Font.ttf(
              await rootBundle.load('assets/fonts/OpenSans-Regular.ttf')),
          bold: pw.Font.ttf(
              await rootBundle.load('assets/fonts/OpenSans-Bold.ttf')),
        ),
        build: (context) {
          List<pw.Widget> widgs = List();
          widgs.add(pw.Row(children: [ pw.Expanded(child: pw.Column(children: [pw.Container(alignment: pw.Alignment.centerLeft, child: pw.Text("MONK Report", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold))),pw.Container(alignment: pw.Alignment.centerLeft, child: pw.Text(DateFormat().addPattern("dd.MM.yy").format(DateTime.now()), style: pw.TextStyle(fontSize: 20)))])),pw.Image(image,width: 80)]));
          widgs.addAll(
              repCall(context));
          return widgs;
        }));

    return document.save();
  }

  static Future<Uint8List> generatePDFFromImages(List<Uint8List> inputs) async {
    final document = pw.Document();

    inputs.forEach((element) async {
      im.Image imgIm = im.decodeImage(element);
      if (imgIm.exif.hasOrientation) {
        switch (imgIm.exif.orientation) {
          case 6:
            imgIm = im.copyRotate(imgIm, 90);
            break;
          case 3:
            imgIm = im.copyRotate(imgIm, 180);
            break;
          case 1:
            // do nothing
            break;
          case 8:
            imgIm = im.copyRotate(imgIm, -90);
            break;
        }
      }
      print("generating file");



      final img = pw.RawImage(bytes: imgIm.getBytes(),width: imgIm.width, height: imgIm.height);

            var aspectR = img.width / img.height;
      PdfPageFormat format;
      var realHeight, realWidth;
      if (img.height > img.width) {
        realWidth = 21.0 * PdfPageFormat.cm;
        realHeight = 21.0 * PdfPageFormat.cm / aspectR;
      } else {
        realWidth = 29.7 * PdfPageFormat.cm;
        realHeight = 29.7 * PdfPageFormat.cm / aspectR;
      }

      print(realWidth);
      print(realHeight);
      format = PdfPageFormat(realWidth, realHeight);

      document.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(img, width: realWidth, height: realHeight),
            ); // Center
          }));
    });

    return document.save();
  }
}
