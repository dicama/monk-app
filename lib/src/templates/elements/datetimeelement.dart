import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class DateTimeElement extends BasicElement {
  final String key = "DateTime";

  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions}) {
    return DateTimeElementWidget(
        input, BasicElement.getOptions(input, parentOptions: parentOptions));
  }
}

class _DateTimeElementState extends State<DateTimeElementWidget> {
  var time;
  var func;
  TimeOfDay tod;
  DateTime date;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    date = BasicElement.getInitialValueDate(widget.options, context, date);
    parseScriptMeta(widget.input);
  }

  parseScriptMeta(String input) {
    Widget returnFunc(BuildContext context) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                DateTime picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(Duration(days: 356)),
                  lastDate: DateTime.now().add(Duration(days: 356)),
                  initialDate: date,
                  builder: (BuildContext context, Widget child) {
                    // TODO: assign correct theme to date time picker bug in material design?
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: Theme(
                          data: Theme.of(context),
                          child: child),
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    date = new DateTime(picked.year, picked.month, picked.day,
                        date.hour, date.minute);
                    BasicElementNotification(
                            widget.options["data"],
                            date.toIso8601String(),
                            BasicElementNotificationType.Data)
                        .dispatch(context);
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).accentColor, width: 2),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  DateFormat("dd.MM.yy").format(date),
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  TimeOfDay picked = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay(hour: date.hour, minute: date.minute),
                    builder: (BuildContext context, Widget child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      date = new DateTime(date.year, date.month, date.day,
                          picked.hour, picked.minute);
                      BasicElementNotification(
                              widget.options["data"],
                              date.toIso8601String(),
                              BasicElementNotificationType.Data)
                          .dispatch(context);
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).accentColor, width: 2),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    DateFormat("HH:mm").format(date),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                )),
          ]);
    }

    func = returnFunc;
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class DateTimeElementWidget extends StatefulWidget {
  final String input;
  final Map options;

  DateTimeElementWidget(this.input, this.options);

  @override
  _DateTimeElementState createState() => _DateTimeElementState();
}
