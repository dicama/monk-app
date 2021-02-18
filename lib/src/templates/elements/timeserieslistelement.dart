import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class TimeSeriesListElement extends BasicElement {
  final String key = "TimeSeriesList";

  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions}) {
    return TimeSeriesListWidget(
        input, moduleId, BasicElement.getOptions(input));
  }
}

class _TimeSeriesListState extends State<TimeSeriesListWidget> {
  var groupVal = -1;
  var func;
  StreamSubscription strSub;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);
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

    final DateFormat dateformat = DateFormat("YYYY.MM.dd");
    final DateFormat dateformat2 = DateFormat.EEEE("de_DE").addPattern("d.M");
    bool initiallyExpanded = false;
    if (widget.options["expanded"] != null &&
        widget.options["expanded"] == "true") {
      initiallyExpanded = true;
    }
    /* test comment added */
    List<dynamic> arrayfrom = AccessLayer().getData(widget.moduleId, datasrc);
    if (arrayfrom == null) {
      arrayfrom = new List();
    }
    var array = List.from(arrayfrom);

    var dayD = 1;
    switch (timespan) {
      case "day":
        dayD = 1;
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
    DateTime start = now.subtract(Duration(days: dayD));

    Map array2 = new Map();
    array.forEach((element) {
      var date1 = DateTime.parse(element["date"]);
      if (date1.isBefore(now) && date1.isAfter(start)) {
        String dayStr = dateformat.format(date1);

        if (array2.containsKey(dayStr)) {
          array2[dayStr].add(element);
        } else {
          array2[dayStr] = [];
          array2[dayStr].add(element);
        }
      }
    });
    var array2keys = array2.keys.toList();
    array2keys.sort((b, a) => a.compareTo(b));

    array2keys.forEach((element) {
      array2[element].sort((a, b) {
        return (DateTime.parse(a["date"])).compareTo(DateTime.parse(b["date"]));
      });
    });

    Widget returnFunc(BuildContext context) {
      return Container(
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: array2keys.length,
            itemBuilder: (context, i) {
              return  ExpansionTile(

                  initiallyExpanded: initiallyExpanded,
                  title: new Text(
                      dateformat2.format(
                          DateTime.parse(array2[array2keys[i]][0]["date"])),
                      style: new TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700
                      )),
                  children: <Widget>[
                    new Column(
                        children:
                            _buildExpandableContent(array2[array2keys[i]])),
                  ]);
            }),
      );
    }

    func = returnFunc;
  }

  Widget getIcon(content, mpi) {
    if (widget.options.containsKey("icon")) {
      String iconAddress = widget.options["icon"];
      if (mpi.containsKey(widget.options["datasrc"] + iconAddress)) {
        if (content[iconAddress.substring(1)] != null) {
          String iconFile = mpi[widget.options["datasrc"] + iconAddress]
              [content[iconAddress.substring(1)]];

          final Widget svgIcon = SvgPicture.asset(
              "assets/icons/pool/" + iconFile,
              color: Color(content["color"]) ?? Colors.black,
              semanticsLabel: 'A red up arrow');
          return svgIcon;
        }
      }

      return Icon(MdiIcons.emoticonPoop);
    } else {
      return Icon(MdiIcons.emoticonPoop);
    }
  }

  _buildExpandableContent(List group) {
    List<Widget> columnContent = [];
    var items = widget.options["items"].split(",");
    Map mp = AccessLayer().getModuleCacheData("vlps");
    Map mpi = AccessLayer().getModuleCacheData("vips");

    for (var content in group)
      columnContent.add(
        new ListTile(
          leading: widget.options["staticicon"] == null
              ? getIcon(content, mpi)
              : Icon(MdiIcons.fromString(widget.options["staticicon"])),
          title: new Text(
            getItemText(
                content[widget.options["title"].substring(1)].toString(),
                mp,
                widget.options["title"]),
            style: new TextStyle(fontSize: 16.0),
          ),
          onTap: () {
            BasicElementNotification(widget.options["datasrc"], ":selected",
                    BasicElementNotificationType.Action)
                .dispatch(context);
            AccessLayer().setModuleCacheData(
                widget.options["datasrc"] + "#selected", content);
          },
          subtitle: Row(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (items.length / 2).round(),
                    itemBuilder: (context, index) {
                      if (index * 2 + 1 < items.length) {
                        return Row(children: [
                          Expanded(
                              child: Text(getItemText(
                                  content[items[index * 2].substring(1)]
                                      .toString(),
                                  mp,
                                  items[index * 2]))),
                          Expanded(
                              child: Text(getItemText(
                                  content[items[index * 2 + 1].substring(1)]
                                      .toString(),
                                  mp,
                                  items[index * 2 + 1])))
                        ]);
                      } else {
                        return Row(children: [
                          Expanded(
                              child: Text(getItemText(
                                  content[items[index * 2].substring(1)]
                                      .toString(),
                                  mp,
                                  items[index * 2])))
                        ]);
                      }
                    }),
              )
            ],
          ),
        ),
      );

    return columnContent;
  }

  trimList(String listRepresentation) {
    if(listRepresentation == "null")
      {
        return "";
      }
    else if (listRepresentation == "[]")
      {
        return "";
      }
    else {
      return "#" +
          listRepresentation.substring(1, listRepresentation.length - 1)
              .replaceAll(", ", " #");
    }
  }

  getItemText(String item, Map mp, address) {
    var df = DateFormat("HH:mm");
    if (address == ".date") {
      return item == null
          ? "NULL"
          : df.format(DateTime.parse(item)) ?? "TimeNotParseable";
    } else if (address == ".tags") {
      return item == null
              ? "NULL"
              : trimList(item);

    } else {
      return mp[widget.options["datasrc"] + address] == null
          ? item == null
              ? "NULL"
              : item
          : mp[widget.options["datasrc"] + address][item].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class TimeSeriesListWidget extends StatefulWidget {
  final Map options;
  final String input;
  final String moduleId;

  TimeSeriesListWidget(this.input, this.moduleId, this.options);

  @override
  _TimeSeriesListState createState() => _TimeSeriesListState();
}
