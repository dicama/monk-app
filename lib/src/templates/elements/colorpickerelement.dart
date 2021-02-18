import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class ColorPickerElement extends BasicElement {
  final String key = "ColorPicker";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return ColorPickerWidget(
        input, BasicElement.getOptions(input, parentOptions: parentOptions));
  }
}

class _ColorPickerState extends State<ColorPickerWidget> {
  final String key = "ColorPicker";
  Color currentColor = Color.fromRGBO(78, 51, 22, 1.0);
  var groupVal = -1;
  var func;

  @override
  void initState() {
    super.initState();
    currentColor = Color(BasicElement.getInitialValueInt(
        widget.options, context, currentColor.value));
    // TODO: Load initial selectedValue.

    parseScriptMeta(widget.input);
  }

  parseScriptMeta(String input) {

    Widget returnFunc(BuildContext context) {
      return Container(
          child: MaterialColorPicker(
            allowShades: false,
            onColorChange: handleColorChange,
            onMainColorChange: handleColorChange,
            selectedColor: currentColor,
            circleSize: 40,
            shrinkWrap: true,
            colors: [
              ColorSwatch(Color.fromRGBO(78, 51, 22, 1.0).value, Map()),
              ColorSwatch(Color.fromRGBO(86, 100, 20, 1.0).value, Map()),
              ColorSwatch(Color.fromRGBO(147, 143, 124, 1.0).value, Map()),
              ColorSwatch(Color.fromRGBO(187, 172, 46, 1.0).value, Map()),
              ColorSwatch(Color.fromRGBO(126, 6, 38, 1.0).value, Map()),
              ColorSwatch(Color.fromRGBO(34, 30, 0, 1.0).value, Map()),
            ],

            // TODO: Make colors as option available.
          ));
    }

    func = returnFunc;
  }

  handleColorChange(Color color) {
    currentColor = color;
    BasicElementNotification(widget.options["data"], color.value,
            BasicElementNotificationType.Data)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class ColorPickerWidget extends StatefulWidget {
  final String input;
  final Map options;

  ColorPickerWidget(this.input, this.options);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}
