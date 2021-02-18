import 'dart:ui';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/pdf_templates/elements/basicpdfelement.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DataPoint {
  final DateTime date;
  final double number;
  final Color color;

  DataPoint(this.date, this.number, this.color);

}

class TimesSeriesBarChartPDFElement extends BasicPDFElement {
  final String key = "TimeSeriesBarChart";


  @override
  List<pw.Widget> parseScript(String input,  pw.Context context,String moduleIdentifier) {
    this.moduleIdentifier = moduleIdentifier;
    Map opts = BasicPDFElement.getOptions(input);

    final String datasrc = opts["datasrc"];
    final String domain = opts["domain"];

    List<pw.LineChartValue> data = List();

    List<String> arguments = datasrc.split(",");
    List<String> properties = [
      arguments[0].split(".")[1],
      arguments[1].split(".")[1]
    ];
    int dayD = 0;
    String dateform = "yMd";
    switch (domain) {
      case "day":
        dayD = 1;
        dateform = "HH";
        break;
      case "week":
        dayD = 7;
        break;
      case "month":
        dayD = 30;
        break;
    }

    DateTime now = DateTime.now();
    now = now
        .subtract(Duration(
            hours: now.hour,
            minutes: now.minute,
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond))
        .add(Duration(days: 1));
    List<dynamic> array = AccessLayer().getData(moduleIdentifier, arguments[0].split(".")[0]);
    DateTime start = now.subtract(Duration(days: dayD));

    var df = DateFormat(dateform);
    var alldays = Map();

    if (domain == "day") {
      DateTime newDate = start;
      while (newDate.isBefore(now)) {
        alldays[df.format(newDate)] = new pw.LineChartValue(newDate.millisecondsSinceEpoch.toDouble(),  0);
        newDate = newDate.add(Duration(hours: 1));
      }
    } else {
      DateTime newDate = start.add(Duration(hours:12));
      while (newDate.isBefore(now)) {
        alldays[df.format(newDate)] = new pw.LineChartValue(newDate.millisecondsSinceEpoch.toDouble(),  0);
        newDate = newDate.add(Duration(days: 1));
      }
    }

    array.forEach((element) {
      var date1 = DateTime.parse(element[properties[0]]);

      if (date1.isAfter(start) && date1.isBefore(now)) {
        if (domain == "day") {
          date1 = date1.subtract(Duration(
              minutes: date1.minute,
              seconds: date1.second,
              milliseconds: date1.millisecond,
              microseconds: date1.microsecond));
        } else {
          date1 = date1
              .subtract(Duration(
                  hours: date1.hour,
                  minutes: date1.minute,
                  seconds: date1.second,
                  milliseconds: date1.millisecond,
                  microseconds: date1.microsecond))
              .add(Duration(hours: 12));
        }

        var val = 1.0;

        if (alldays.containsKey(df.format(date1))) {
          val += alldays[df.format(date1)].y;
        }
        alldays[df.format(date1)] =
            new pw.LineChartValue(date1.millisecondsSinceEpoch.toDouble(), val);
      }
    });

    print("################### " + domain);
    List<int> xasx = List();
    double maxVal = 0;

    alldays.keys.toList().forEach((element) {
      data.add(alldays[element]);
      xasx.add(alldays[element].x.round());
      if(alldays[element].y > maxVal)
        {
          maxVal = alldays[element].y;
        }
    });

    final chart2 = pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis(xasx,
          format: (v)  => DateTime.fromMillisecondsSinceEpoch(v.round()).day%3==0 ? DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(v.round())) : "",
          ticks: true,
        ),
        yAxis: pw.FixedAxis(
          [0, maxVal.round()],
          divisions: true,
        ),

      ),
      datasets: [
      pw.BarDataSet(
      color: PdfColor.fromInt(Color.fromRGBO(78, 51, 22, 1.0).value),
      width: 10,
      borderColor: PdfColor.fromInt(Color.fromRGBO(78, 51, 22, 1.0).value),
      data: data),
          /*pw.LineDataSet(
          drawSurface: true,
          isCurved: true,
          drawPoints: false,
          color: PdfColor.fromInt(Colors.lightGreen.value),
          data: data, /*List<pw.LineChartValue>.generate(
            dataTable.length,
                (i) {
              final num v = dataTable[i][2];
              return pw.LineChartValue(i.toDouble(), v.toDouble());
            },
          )*/
        ),*/
      ],
    );

    return [chart2];
  }
}

