import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DataPoint {
  final DateTime date;
  final double number;
  final charts.Color color;

  DataPoint(this.date, this.number, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class TimeSeriesStatisticsElement extends BasicElement {
  final String key = "TimeSeriesStatistics";

  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions}) {
    return TimeSeriesStatisticsElementWidget(
        input, moduleId, BasicElement.getOptions(input));
  }
}

class _TimeSeriesStatisticsElementState
    extends State<TimeSeriesStatisticsElementWidget> {
  var groupVal = -1;
  var func;
  List<DataPoint> data = [];
  StreamSubscription strSub;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
    strSub = AccessLayer().getWriteStream().stream.listen((value) {
      if (value == widget.options["datasrc"]) {
        setState(() {
          parseScriptMeta(widget.input);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    strSub?.cancel();
  }

  void parseScriptMeta(String input) {
    final String datasrc = widget.options["datasrc"];
    final String timespan = widget.options["timespan"];
    var decimalCount = 1;
    if (widget.options.containsKey("decimal")) {
      decimalCount = int.parse(widget.options["decimal"]);
    }

    List<dynamic> array = AccessLayer().getData(widget.moduleId, datasrc);
    if (array == null) {
      array = new List();
    }
    DateTime now;
    DateTime start;
    DateTime startbefore;
    now = DateTime.now();
    now = now
        .subtract(Duration(
            hours: now.hour,
            minutes: now.minute,
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond))
        .add(Duration(days: 1));

    if (timespan == "month") {
      start = now.subtract(Duration(days: 30));
      startbefore = now.subtract(Duration(days: 60));
    } else if (timespan == "week") {
      start = now.subtract(Duration(days: 7));
      startbefore = now.subtract(Duration(days: 14));
    } else if (timespan == "day") {
      start = now.subtract(Duration(days: 1));
      startbefore = now.subtract(Duration(days: 2));
    }

    var count1 = 0.0;
    var count2 = 0.0;
    String textOut = "";
    String sign = "+-";
    var diff = "";
    if (widget.options["accumulate"] == "count") {
      array.forEach((element) {
        var date1 = DateTime.parse(element["date"]);
        if (date1.isBefore(now) && date1.isAfter(start)) {
          count1++;
        } else if (date1.isBefore(start) && date1.isAfter(startbefore)) {
          count2++;
        }
      });

      if (count1 - count2 > 0) {
        sign = "+";
      } else if (count1 - count2 < 0) {
        sign = "";
      }
      diff = "$sign${count1 - count2}";
      if (count2 > 0) {
        diff = "$sign${(((count1 - count2) / count2) * 100).round()}\%";
      }
    } else if (widget.options["accumulate"] == "avg") {
      var count1count = 0;
      var count2count = 0;
      array.forEach((element) {
        var date1 = DateTime.parse(element["date"]);
        if (date1.isBefore(now) && date1.isAfter(start)) {
          count1 += double.parse(element["value"].toString());
          count1count++;
        } else if (date1.isBefore(start) && date1.isAfter(startbefore)) {
          count2 += double.parse(element["value"].toString());
          count2count++;
        }
      });
      if (count1count > 1) {
        count1 = count1 / count1count;
      }
      if (count2count > 1) {
        count2 = count2 / count2count;
      }
      if (count1 - count2 > 0) {
        sign = "+";
      } else if (count1 - count2 < 0) {
        sign = "";
      }
      diff = "$sign${(count1 - count2).toStringAsFixed(decimalCount)}";
    }

    String under = "";
    if (widget.options["accumulate"] == "count") {
      if (timespan == "month") {
        textOut =
            "${count1.round()}${widget.options["middlestring"]} in den letzen 30 Tagen";
        under = "$diff im Vergleich zum Vormonat";
      } else if (timespan == "week") {
        textOut =
            "${count1.round()}${widget.options["middlestring"]} in den letzten 7 Tagen";
        under = "$diff im Vergleich zur Vorwoche";
      } else if (timespan == "day") {
        textOut =
            "${count1.round()}${widget.options["middlestring"]} heute ($diff)";
        under = "$diff im Vergleich zu gestern";
      }
    } else if (widget.options["accumulate"] == "avg") {
      if (timespan == "month") {
        textOut =
            "${count1.toStringAsFixed(decimalCount)}${widget.options["middlestring"]} in den letzen 30 Tagen";
        under = "$diff im Vergleich zum Vormonat";
      } else if (timespan == "week") {
        textOut =
            "${count1.toStringAsFixed(decimalCount)}${widget.options["middlestring"]} in den letzten 7 Tagen";
        under = "$diff im Vergleich zur Vorwoche";
      } else if (timespan == "day") {
        textOut =
            "${count1.toStringAsFixed(decimalCount)}${widget.options["middlestring"]} heute";
      }
    }

    func = (BuildContext context) {
      return Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(textOut,
                    style: Theme.of(context).textTheme.headline6)),
            Align(
                alignment: Alignment.centerLeft,
                child:
                    Text(under, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.grey.shade700), ))
          ]),
          padding: EdgeInsets.all(12));
    };
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class TimeSeriesStatisticsElementWidget extends StatefulWidget {
  final String input;
  final String moduleId;
  final Map options;

  TimeSeriesStatisticsElementWidget(this.input, this.moduleId, this.options);

  @override
  _TimeSeriesStatisticsElementState createState() =>
      _TimeSeriesStatisticsElementState();
}
