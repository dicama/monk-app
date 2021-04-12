import 'dart:ui';

import 'package:monk/src/pdf_templates/elements/basicpdfelement.dart';
import 'package:pdf/widgets.dart' as pw;

class DataPoint {
  final DateTime date;
  final double number;
  final Color color;

  DataPoint(this.date, this.number, this.color);

}

class SizedBoxPDFElement extends BasicPDFElement {
  final String key = "SizedBox";

  @override
  List<pw.Widget> parseScript(String input, pw.Context context, String moduleIdentifier) {

    Map opts = BasicPDFElement.getOptions(input);
    double height = 10;
    double width = 10;
    if(opts.keys.contains("height"))
    {
      height=double.parse(opts["height"]);
    }

    if(opts.keys.contains("width"))
    {
      width=double.parse(opts["width"]);
    }
    final out = pw.SizedBox(width: width, height: height);
    return [out];
  }
}

