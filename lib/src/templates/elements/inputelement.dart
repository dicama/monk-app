import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class InputElement extends BasicElement {
  final String key = "Input";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return InputWidget(input, moduleId);
  }
}

class _InputState extends State<InputWidget> {
  var groupVal = -1;
  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
  }

  void parseScriptMeta(String input) {
    final String inner = BasicElement.getInnerString(input, "[", "]");
    final TextEditingController _controller =
        new TextEditingController(text: AccessLayer().getString(widget.moduleId, inner));
    _controller.addListener(() {
      AccessLayer().setData(widget.moduleId, inner, _controller.value.text);
    });
    Widget returnFunc(BuildContext context) {
      _controller.text = AccessLayer().getString(widget.moduleId, inner);
      return TextField(controller: _controller);
    }

    func = returnFunc;
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class InputWidget extends StatefulWidget {

  final String input;
  final String moduleId;

  InputWidget(this.input, this.moduleId);

  @override
  _InputState createState() => _InputState();
}
