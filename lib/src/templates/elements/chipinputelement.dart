import 'package:flutter/material.dart';
import 'package:monk/src/customwidgets/addabletags.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'basicelement.dart';

class ChipInputElement extends BasicElement {
  final String key = "ChipInput";

  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions}) {
    return ChipInputWidget(input,  BasicElement.getOptions(input, parentOptions: parentOptions), moduleId);
  }
}

class ChipInputWidget extends StatefulWidget {
  final input;
  final Function(String) onSelectionChanged;
  final Map options;
  final moduleId;

  ChipInputWidget(this.input, this.options, this.moduleId,
      {this.onSelectionChanged});

  @override
  _ChipInputState createState() => _ChipInputState();
}

class _ChipInputState extends State<ChipInputWidget> {
  List<String> selectedChoice ;

  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
    selectedChoice = BasicElement.getInitialValueListString(widget.options, context, null);
    print("inital String value");
    print(selectedChoice.toString());
  }

  void parseScriptMeta(String input) {
    Map<String,int> tagcloud = Map();
    if (widget.options.keys.contains("dataparent")) {
      var elements =
          AccessLayer().getData(widget.moduleId, widget.options["dataparent"],
              defaultVal: new List());
      final String dataaddress = widget.options["data"].substring(1);
      elements.forEach((ele) {
        if (ele.containsKey(dataaddress)) {
          ele[dataaddress].forEach( (tag) {
          if (tagcloud.containsKey(tag)) {
            tagcloud[tag] += 1;
          } else {
            tagcloud[tag] = 1;
          }
          }
        );
        }
      });
    }

    final List<String> sortedKeys = tagcloud.keys.toList(growable: false)
      ..sort((k1, k2) => -tagcloud[k1].compareTo(tagcloud[k2]));



    Widget returnFunc(BuildContext context) {
      List<String> initals = [];
      print(selectedChoice);
      print("not adding");
      if(selectedChoice != null)
      {
        print("adding");
        initals.addAll(selectedChoice);
      }
      initals.addAll(sortedKeys.take(5).toList());

      Widget widg = AddableTagsWidget(initals.toSet().toList(), selectedList: selectedChoice ?? [], onSelection: (List<String> selectedTags) { BasicElementNotification(widget.options["data"], selectedTags,
          BasicElementNotificationType.Data)
          .dispatch(context);},);
      return widg;
    }

    func = returnFunc;
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

