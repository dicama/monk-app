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

class TimesSeriesChartPDFElement extends BasicPDFElement {
  final String key = "TimeSeriesChart";

  @override
  List<pw.Widget> parseScript(
      String input, pw.Context context, String moduleIdentifier) {
    this.moduleIdentifier = moduleIdentifier;
    Map opts = BasicPDFElement.getOptions(input);

    final String datasrc = opts["datasrc"];
    final String domain = opts["domain"];
    print("parsing TimeSeriesChart");
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
    List<dynamic> array =
        AccessLayer().getData(moduleIdentifier, arguments[0].split(".")[0]);
    DateTime start = now.subtract(Duration(days: dayD));

    var df = DateFormat(dateform);
    var alldays = Map();

    List<int> xasx = List();
    if (domain == "day") {
      DateTime newDate = start;
      while (newDate.isBefore(now)) {
        xasx.add(newDate.millisecondsSinceEpoch);
        newDate = newDate.add(Duration(hours: 1));
      }
    } else {
      DateTime newDate = start.add(Duration(hours: 12));
      while (newDate.isBefore(now)) {
        xasx.add(newDate.millisecondsSinceEpoch);
        newDate = newDate.add(Duration(days: 1));
      }
    }

    array.forEach((element) {
      var date1 = DateTime.parse(element[properties[0]]);

      if (date1.isAfter(start) && date1.isBefore(now)) {
        alldays[date1.toIso8601String()] = new pw.LineChartValue(
            date1.millisecondsSinceEpoch.toDouble(), element["value"]);
      }
    });

    print("################### " + domain);

    double maxVal = 0;
    double minVal = 1000;

    alldays.keys.toList().forEach((element) {
      data.add(alldays[element]);
      if (alldays[element].y > maxVal) {
        maxVal = alldays[element].y;
      }
      if (alldays[element].y < minVal) {
        minVal = alldays[element].y;
      }
    });

    if (minVal > maxVal) {
      minVal = maxVal;
    }

    xasx.sort((a, b) {
      return (a - b).round();
    });

    final chart2 = pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis(
          xasx,
          format: (v) =>
              DateTime.fromMillisecondsSinceEpoch(v.round()).day % 3 == 0
                  ? DateFormat.d()
                      .format(DateTime.fromMillisecondsSinceEpoch(v.round()))
                  : "",
          ticks: true,
        ),
        yAxis: pw.FixedAxis(
          [minVal.round() - 2, maxVal.round() + 2],
          divisions: true,
        ),
      ),
      datasets: [
        pw.LineDataSet(
            color: PdfColor.fromInt(Colors.blue.value),
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
