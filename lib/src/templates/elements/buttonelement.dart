import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class ButtonElement extends BasicElement {
  final String key = "Button";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return ButtonElementWidget(input, BasicElement.getOptions(input, parentOptions: parentOptions));
  }
}

class _ButtonElementState extends State<ButtonElementWidget> {
  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
  }

  void parseScriptMeta(String input) {
    if (widget.options.containsKey("mode") &&
        widget.options["parent"].containsKey("mode")) {
      if (widget.options["mode"] != widget.options["parent"]["mode"]) {
        func = (BuildContext context1) {
          return Container();
        };
        return;
      }
    }

    Widget returnFunc(BuildContext context) {
      return FlatButton(color: Theme.of(context).accentColor,
        child: Text(widget.options["label"]),
        onPressed: handlePress,
      );
    }

    func = returnFunc;
  }

  handlePress() {
    BasicElementNotification(
            widget.options["action"], null, BasicElementNotificationType.Action)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class ButtonElementWidget extends StatefulWidget {
  final String input;
  final Map options;

  ButtonElementWidget(this.input, this.options);

  @override
  _ButtonElementState createState() => _ButtonElementState();
}
