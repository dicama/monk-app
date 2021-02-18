import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';

import 'basicelement.dart';

class SelectTileElement extends BasicElement {
  final String key = "SelectTile";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return SelectTileWidget(input, BasicElement.getOptions(input, parentOptions: parentOptions));
  }
}

class SelectTileWidget extends StatefulWidget {
  final input;
  final Function(String) onSelectionChanged;
  final Map options;

  SelectTileWidget(this.input, this.options, {this.onSelectionChanged});

  @override
  _SelectTileState createState() => _SelectTileState();
}

class _SelectTileState extends State<SelectTileWidget> {
  String selectedChoice = "";

  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
    selectedChoice = BasicElement.getInitialValueString(widget.options, context, "");
  }

  Widget getIcon(value, mpi) {

    if (mpi
        .containsKey(widget.options["dataparent"] + widget.options["data"])) {
      String iconFile =
          mpi[widget.options["dataparent"] + widget.options["data"]][value];

       final Widget svgIcon = SvgPicture.asset(
        "assets/icons/pool/" + iconFile,
        color: Colors.black.withOpacity(0.8)
      );

      return svgIcon;
    }

    return Icon(MdiIcons.emoticonPoop);
  }

  void parseScriptMeta(String input) {
    List<String> strChoices = widget.options["choices"].split("#");
    Map mpi = AccessLayer().getModuleCacheData("vips");

    Widget returnFunc(BuildContext context) {
      List<Widget> choices = List();
      strChoices.forEach((item) {
        choices.add( RadioListTile(
          value: item,
          secondary: getIcon(item, mpi),
          groupValue: selectedChoice,
          title: Container(
              padding: EdgeInsets.all(5),
              child: Text(
                item,
                style: Theme.of(context).textTheme.subtitle1,
              )),
          onChanged: (String val) {
            setState(() {
              selectedChoice = val;
              BasicElementNotification(widget.options["data"], selectedChoice,
                  BasicElementNotificationType.Data)
                  .dispatch(context);
                /*widget.onSelectionChanged(selectedChoice);*/
            });
          },
        ));
      });
      return new Wrap(children: choices);
    }

    func = returnFunc;
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}
