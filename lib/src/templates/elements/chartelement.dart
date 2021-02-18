import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

extension MyDateUtils on DateTime {
  DateTime copyWith(
      {int year,
      int month,
      int day,
      int hour,
      int minute,
      int second,
      int millisecond,
      int microsecond}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

class DataPoint {
  final DateTime date;
  final double number;
  final charts.Color color;

  DataPoint(this.date, this.number, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class ChartElement extends BasicElement {
  final String key = "ChartSpark";

  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions}) {
    return ChartElementWidget(input, moduleId, BasicElement.getOptions(input));
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

class _ChartElementState extends State<ChartElementWidget> {
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

    //TODO christoph: kann das ein security-Problem sein? also der writestream
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

  /*charts.AxisSpec getDomainAxis() {
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
      return charts.AxisSpec(
          viewport: charts.DateTimeExtents(
              start: now.subtract(Duration(days: 31)), end: now));
    } else if (domain == "week") {
      return charts.AxisSpec(
          viewport: charts.DateTimeExtents(
              start: now.subtract(Duration(days: 7)), end: now));
    } else {
      return charts.AxisSpec(
          viewport: charts.DateTimeExtents(
              start: now.subtract(Duration(days: 1)), end: now));
    }
  }*/

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
        df = DateFormat.E("de_DE"); // TODO: do not use hard coded localization
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
    List<dynamic> array =
        AccessLayer().getData(widget.moduleId, arguments[0].split(".")[0]);
    DateTime start = now.subtract(Duration(days: dayD));

    var df = DateFormat(dateform);
    var alldays = Map();
    var alldays_count = Map();

    if (domain == "day") {
      DateTime newDate = start;
      while (newDate.isBefore(now)) {
        alldays[df.format(newDate)] = DataPoint(newDate, 0, Colors.grey);
        alldays_count[df.format(newDate)] = 0;
        newDate = newDate.add(Duration(hours: 1));
      }
    } else {
      DateTime newDate = start;
      while (newDate.isBefore(now)) {
        alldays[df.format(newDate)] = DataPoint(newDate, 0, Colors.grey);
        alldays_count[df.format(newDate)] = 0;
        newDate = newDate.add(Duration(days: 1));
      }
    }

    array.forEach((element) {
      var date1 = DateTime.parse(element[properties[0]]);
      var value;

      if (element["value"] != null) {
        value = double.parse(element["value"].toString());
      } else {
        value = 1;
      }

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

        var val = value;

        if (alldays.containsKey(df.format(date1))) {
          val += alldays[df.format(date1)].number;
          alldays_count[df.format(date1)] = alldays_count[df.format(date1)] + 1;
        }
        alldays[df.format(date1)] =
            new DataPoint(date1, val, Color(element[properties[1]]));
      }
    });

    List<charts.TickSpec<String>> yo = new List();
    alldays.keys.toList().forEach((element) {
      if (widget.options["accumulate"] == "avg" && alldays_count[element] > 1) {
        DataPoint newdat = new DataPoint(
            alldays[element].date,
            alldays[element].number / alldays_count[element],
            Color.fromARGB(alldays[element].color.a, alldays[element].color.r,
                alldays[element].color.g, alldays[element].color.b));

        data.add(newdat);
      } else {
        data.add(alldays[element]);
      }
      yo.add(charts.TickSpec(element, label: getLabel(alldays[element].date)));
    });

    var series = [
      new charts.Series<DataPoint, String>(
        id: 'Poop',
        domainFn: (DataPoint clickData, _) => df.format(clickData.date),
        measureFn: (DataPoint clickData, _) => clickData.number,
        colorFn: (DataPoint clickData, _) => clickData.color,
        data: data,
      ),
    ];
    var chart = new charts.BarChart(
      series,
      animate: true,
      // Set the default renderer to a bar renderer.
      // This can also be one of the custom renderers of the time series chart.
      // It is recommended that default interactions be turned off if using bar
      // renderer, because the line point highlighter is the default for time
      // series chart,
      domainAxis: new charts.OrdinalAxisSpec(
          tickProviderSpec: charts.StaticOrdinalTickProviderSpec(yo),
          renderSpec:
              charts.SmallTickRendererSpec(minimumPaddingBetweenLabelsPx: 10)),
      defaultInteractions: false,
      /*domainAxis: getDomainAxis(),*/
      // If default interactions were removed, optionally add select nearest
      // and the domain highlighter that are typical for bar charts.
      /*behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],*/
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

class ChartElementWidget extends StatefulWidget {
  final String input;
  final String moduleId;
  final Map options;

  ChartElementWidget(this.input, this.moduleId, this.options);

  @override
  _ChartElementState createState() => _ChartElementState();
}
