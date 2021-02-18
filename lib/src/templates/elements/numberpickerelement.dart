import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/module.dart';
import 'package:numberpicker/numberpicker.dart';
import 'basicelement.dart';

class NumberPickerElement extends BasicElement {
  final String key = "NumberPicker";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return NumberPickerWidget(input, BasicElement.getOptions(input));
  }
}

class NumberPickerWidget extends StatefulWidget {
  final input;
  final Function(String) onSelectionChanged;
  final Map options;

  NumberPickerWidget(this.input, this.options, {this.onSelectionChanged});

  @override
  _NumberPickerState createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPickerWidget> {

  var selectedNumber;
  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
    if (widget.options.containsKey("defaultvalue")) {
      selectedNumber = double.parse(widget.options["defaultvalue"]);
      BasicElementNotification(widget.options["data"], selectedNumber,
              BasicElementNotificationType.Data)
          .dispatch(context);
    }
  }

  Widget getIcon(value, mpi) {
    print("GET ICON");
    if (mpi
        .containsKey(widget.options["dataparent"] + widget.options["data"])) {
      String iconFile =
          mpi[widget.options["dataparent"] + widget.options["data"]][value];

      print("ICONFILE" + iconFile);
      final Widget svgIcon = SvgPicture.asset(
        "assets/icons/pool/" + iconFile,
        color: Colors.black,
      );
      return svgIcon;
    }

    return Icon(MdiIcons.emoticonPoop);
  }

  void _handleChange(num)
  {
    setState(() {selectedNumber = num;});

    BasicElementNotification(widget.options["data"], selectedNumber,
        BasicElementNotificationType.Data)
        .dispatch(context);
  }

  void parseScriptMeta(String input) {
    Widget returnFunc(BuildContext context) {
      Widget widg = NumberPicker.decimal(
          initialValue: selectedNumber,
          minValue: 0,
          maxValue: 160,
          decimalPlaces: 1,
          onChanged: _handleChange);
      return widg;
    }

    func = returnFunc;
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}
