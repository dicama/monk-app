import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monk/src/pdf_templates/elements/basicpdfelement.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:pdf/widgets.dart' as pw;

final int brownCol = Color.fromRGBO(78, 51, 22, 1.0).value;
final int  greenCol = Color.fromRGBO(86, 100, 20, 1.0).value;
final int  lehmCol = Color.fromRGBO(147, 143, 124, 1.0).value;
final int  yelCol =Color.fromRGBO(187, 172, 46, 1.0).value;
final int  rotCol =Color.fromRGBO(126, 6, 38, 1.0).value;
final int  schwarzCol =Color.fromRGBO(34, 30, 0, 1.0).value;


Map<int,String> colorValueToName =
{
  brownCol: "braun",
    greenCol: "grün",
    lehmCol: "lehm",
    yelCol:  "gelb",
    rotCol: "rot",
    schwarzCol: "schw."
};




class TimeSeriesToTablePDFElement extends BasicPDFElement {
  final String key = "TimeSeriesToTable";


  String convertEntryToString(dynamic value, String type)
  {
    String ret = "";
    switch(type)
    {
      case "text":
        ret = value.toString();
        break;
      case "list":
        ret = value.join(",");
        break;
      case "date":
        DateTime dat = DateTime.parse(value);
        ret = DateFormat().addPattern("dd.MM.yy HH:mm").format(dat);
        break;
      case "color":
        if(colorValueToName.keys.contains(value)) {
          ret = colorValueToName[value];
        }
        else{
          ret = value.String();
        }

        break;
      case "number":
        ret = value.toString();
        break;

    }
    return ret;

  }

  @override
  List<pw.Widget> parseScript(String input, pw.Context context, String moduleIdentifier) {
    var opts = BasicPDFElement.getOptions(input);
    List<dynamic> series = AccessLayer().getData(moduleIdentifier, opts["series"]);




    print(series);
    List<List<String>> stringList = new List();

    List<String> titles = opts["titles"].split(",");
    List<String> types = opts["types"].split(",");
    List<String> show = opts["show"].split(",");


    stringList.add(titles);

    for(var n in series)
    {
      List<String> lineList = List();
      for(int i = 0; i< show.length;i++)
      {
        lineList.add(convertEntryToString(n[show[i]], types[i]));
      }
      stringList.add(lineList);
    }

    print(stringList);

    final out = pw.Table.fromTextArray(context: context, data: stringList);

    /*
    this.moduleIdentifier = moduleIdentifier;
    Map opts = BasicPDFElement.getOptions(input);
    final out = pw.Text(opts["text"]);*/
    return [out];
  }
}

