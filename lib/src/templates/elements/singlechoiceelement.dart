import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class SingleChoiceElement extends BasicElement {
  final String key = "SingleChoice";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return SingleChoiceWidget(input, BasicElement.getOptions(input, parentOptions: parentOptions));
  }

}

class _SingleChoiceState extends State<SingleChoiceWidget> {

  var groupVal = "";
  var func;
  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
    groupVal = BasicElement.getInitialValueString(widget.options, context, "");
  }

    List<Widget> getRadios()
    {
      List<Widget> ret= new List<Widget>();
      List<String> values = widget.options["values"].split(",");
      List<String> labels = widget.options["labels"].split(",");

      for(var i = 0; i< values.length; i++)
      {
        ret.add(new Radio(
          value: values[i],
          groupValue: groupVal,
          onChanged: (var value) {
            setState(() {
              groupVal = value;
              BasicElementNotification(widget.options["data"], groupVal, BasicElementNotificationType.Data).dispatch(context);
            });
          },
        ),);
        ret.add(new Text(
          labels[i],
          style: new TextStyle(fontSize: 16.0),
        ),);

      }

      return ret;

    }

    parseScriptMeta(String input) {

    Widget returnFunc(BuildContext context) {
      print("regenerating");

      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getRadios());
    }

    func = returnFunc;
  }


  @override
  Widget build(BuildContext context) {
    return func(context);
  }

}


class SingleChoiceWidget extends StatefulWidget {
  final Map options;
  final String input;

  SingleChoiceWidget(this.input, this.options);

  @override
  _SingleChoiceState createState() => _SingleChoiceState();


}
