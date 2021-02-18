import 'dart:ui';

import 'package:monk/src/pdf_templates/elements/basicpdfelement.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DataPoint {
  final DateTime date;
  final double number;
  final Color color;

  DataPoint(this.date, this.number, this.color);

}

class TextPDFElement extends BasicPDFElement {
  final String key = "Text";

  @override
  List<pw.Widget> parseScript(String input, pw.Context context, String moduleIdentifier) {
    this.moduleIdentifier = moduleIdentifier;
    Map opts = BasicPDFElement.getOptions(input);
    double size = 12;
    if(opts.keys.contains("size"))
    {
      size=double.parse(opts["size"]);
    }
    final out = pw.Text(opts["text"], style: pw.TextStyle(fontSize: size));
    return [out];
  }
}

