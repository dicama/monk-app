import 'package:flutter/material.dart';
import 'package:monk/src/bars/modalbar.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:monk/src/templates/generator.dart';
import 'package:monk/tools.dart';

import '../extendedstate.dart';

class ModalBundle {
  ModalBundle(this.input, this.moduleId, this.options);

  final String input;
  final String moduleId;
  final Map options;
}

class _ModalState extends State<Modal> {
  List<List<Widget>> widg = new List<List<Widget>>();
  bool first = true;
  var locals = Map();

  void updateWidget() {
    setState(() {
      print("updating");
    });
  }

  void initState() {
    super.initState();
    /*locals.setDelegate(updateWidget);*/
    /*funcs.add(new List<Function>());*/
    widg.add(new List<Widget>());
    if (widget.options.containsKey("data")) {
      if (widget.options["data"].toString().contains(":")) {
        locals["element"] = Map<String, Object>();
      }
    }
    print("before access");
    widg[0] = WidgetGenerator.parseStringMeta(
        widget.input, null, widget.moduleId,
        parentOptions: widget.options);
  }

  List<Widget> getWidget(BuildContext bc) {
    return widg[0];
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      appBar: ModalBar.build(context, widget.options["title"]),
      body: NotificationListener<BasicElementNotification>(
        onNotification: (notification) {
          handleNotification(notification);
          return true;
        },
        child: ListView(padding: const EdgeInsets.all(8), children: widg[0]),
        /*getWidget(context, locals),*/
      ),
    );
  }

  void fillTimeSeriesDefaults() {
    if (locals["element"]["color"] == null) {
      locals["element"]["color"] = Colors.blue.value;
    }

    if (locals["element"]["date"] == null) {
      locals["element"]["date"] = DateTime.now().toIso8601String();
    }

    if (locals["element"]["value"] == null) {
      locals["element"]["value"] = 0;
    }
  }

  void handleNotification(BasicElementNotification not) {
    if (not.type == BasicElementNotificationType.Data) {
      if (not.key.startsWith(".")) {
        if (locals.containsKey("element")) {
          locals["element"][not.key.substring(1)] = not.value;
          print(locals["element"]);
        }
      }
    } else if (not.type == BasicElementNotificationType.Action) {
      if (not.key == "saveandclose") {
        // save and close
        if (widget.options["data"].toString().contains(":element")) {
          String address = widget.options["data"].toString().split(":")[0];

          fillTimeSeriesDefaults();

          List<dynamic> array = AccessLayer().getData(widget.moduleId, address,
            defaultVal: new List());

          if (widget.options.containsKey("mode") &&
              widget.options["mode"] == "edit") {
            var res = AccessLayer().getModuleCacheData(address + "#selected");
            dynamic findSelected() =>
                array.firstWhere((item) => item["date"] == res["date"]);
            array.remove(findSelected());
            array.add(locals["element"]);
            print("replacing with :" + locals["element"].toString());
            AccessLayer().setData(widget.moduleId, address, array);

          } else {
            array.add(locals["element"]);
            AccessLayer().setData(widget.moduleId, address, array);
          }

          if (safeCheckMapEntry(widget.options, "trigger_last_entry", "true")) {
            AccessLayer().setModuleData(
                widget.moduleId, "last_entry", DateTime.now().toIso8601String());
          }

          Navigator.of(context).pop();
        }
      } else if (not.key == "deleteandclose") {
        // save and close
        if (widget.options.containsKey("mode") &&
            widget.options["mode"] == "edit") {
          if (widget.options["data"].toString().contains(":element")) {
            String address = widget.options["data"].toString().split(":")[0];
            List<dynamic> array =
                AccessLayer().getData(widget.moduleId, address);
            var res = AccessLayer().getModuleCacheData(address + "#selected");
            dynamic findSelected() =>
                array.firstWhere((item) => item["date"] == res["date"]);

            array.remove(findSelected());
            print(widget.moduleId);
            AccessLayer().setData(widget.moduleId, address, array);
          }

          if (safeCheckMapEntry(widget.options, "trigger_last_entry", "true")) {
            print(widget.moduleId);
            AccessLayer().setModuleData(
                widget.moduleId, "last_entry", DateTime.now().toIso8601String());
          }

          Navigator.of(context).pop();
        }
      }
    }
  }
}

class Modal extends ExtendedStatefulWidget {
  final String input;
  final String moduleId;
  final Map options;

  Modal(this.input, this.moduleId, this.options, {Map locals}) {
    this.locals = locals;
  }

  @override
  _ModalState createState() => _ModalState();
}
