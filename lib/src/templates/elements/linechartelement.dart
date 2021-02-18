import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';



class DataPoint {
  final DateTime date;
  final double number;
  final charts.Color color;

  DataPoint(this.date, this.number, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class LineChartElement extends BasicElement {
  final String key = "LineTSChart";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return LineChartElementWidget(input, moduleId, BasicElement.getOptions(input));
  }
}

Widget parseScript(String input, Module parent) {
  String inner = BasicElement.getInnerString(input, "[", "]");
  return Container(
    child: WebView(
      initialUrl: inner,
    ),
  );
}

class _LineChartElementState extends State<LineChartElementWidget> {
  var groupVal = -1;
  var func;
  List<DataPoint> data = [];
  StreamSubscription strsub;
  String domain = "day";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);
    domain = widget.options["domain"];
    strsub = AccessLayer().getWriteStream().stream.listen((value) {
      if (value == widget.options["datasrc"].split(".")[0]) {
        setState(() {
          parseScriptMeta(widget.input);
        });
      }
    });
    parseScriptMeta(widget.input);
  }

  void loadRest() {}

  void dispose() {
    super.dispose();

    strsub?.cancel();
  }

 charts.DateTimeAxisSpec getDomainAxis() {
    final String domain = widget.options["domain"];
    DateTime now = DateTime.now();
    now = now
        .subtract(Duration(
            hours: now.hour,
            minutes: now.minute,
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond))
        .add(Duration(days: 1));

    if (domain == "month") {
      return charts.DateTimeAxisSpec(
          viewport: charts.DateTimeExtents(
              start: now.subtract(Duration(days: 31)), end: now));
    } else if (domain == "week") {
      return charts.DateTimeAxisSpec(
          viewport: charts.DateTimeExtents(
              start: now.subtract(Duration(days: 7)), end: now));
    } else {
      return charts.DateTimeAxisSpec(
          viewport: charts.DateTimeExtents(
              start: now.subtract(Duration(days: 1)), end: now));
    }
  }

  String getLabel(DateTime date) {
    DateFormat df;

    switch (domain) {
      case "day":
        if (date.hour % 3 == 0) {
          df = DateFormat("H");
          return df.format(date);
        } else {
          return "";
        }
        break;
      case "week":
        df = DateFormat.E("de_DE");
        return df.format(date);
        break;
      case "month":
        if (date.day % 3 == 0) {
          df = DateFormat("d");
          return df.format(date);
        } else {
          return "";
        }

        break;
    }
  }

  void parseScriptMeta(String input) {
    final String datasrc = widget.options["datasrc"];
    final String domain = widget.options["domain"];

    data = [];

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
    List<dynamic> array = AccessLayer().getData(widget.moduleId, arguments[0].split(".")[0]);
    DateTime start = now.subtract(Duration(days: dayD));

    var df = DateFormat(dateform);

    array.forEach((element) {
      var date1 = DateTime.parse(element[properties[0]]);
        data.add(DataPoint(date1, element["value"], Color(element[properties[1]])));
      }
    );

    data.sort((a,b) {return a.date.compareTo(b.date);});

    var series = [
      new charts.Series<DataPoint, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DataPoint sales, _) => sales.date,
        measureFn: (DataPoint sales, _) => sales.number,
        data: data,
      )
    ];
    var chart = new charts.TimeSeriesChart(
      series,
      animate: false,
        defaultRenderer: new charts.LineRendererConfig(includePoints: true),
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(zeroBound: false)),
      domainAxis: getDomainAxis(),
    );

    func = (BuildContext context) => Container(
          height: double.parse(widget.options["height"]) + 16,
          child: new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new SizedBox(
              height: double.parse(widget.options["height"]),
              child: chart,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class LineChartElementWidget extends StatefulWidget {
  final String input;
  final String moduleId;
  final Map options;

  LineChartElementWidget(this.input, this.moduleId, this.options);

  @override
  _LineChartElementState createState() => _LineChartElementState();
}
