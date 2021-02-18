import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';

import 'basicelement.dart';



class SelectChipElement extends BasicElement {
  final String key = "SelectChip";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {

    return SelectChipWidget(input, BasicElement.getOptions(input));
  }
}


class SelectChipWidget extends StatefulWidget {
  final input;
  final Function(String) onSelectionChanged;
  final Map options;
  SelectChipWidget(this.input,this.options, {this.onSelectionChanged});

  @override
  _SelectChipState createState() => _SelectChipState();
}
class _SelectChipState extends State<SelectChipWidget> {
  String selectedChoice = "";


  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
    if(widget.options.containsKey("defaultvalue"))
    {
      selectedChoice = widget.options["defaultvalue"];
      BasicElementNotification(widget.options["data"], selectedChoice, BasicElementNotificationType.Data).dispatch(context);
    }

  }

  Widget getIcon(value, mpi)
  {

    print("GET ICON");
      if(mpi.containsKey(widget.options["dataparent"] + widget.options["data"])) {
          String iconFile = mpi[widget.options["dataparent"] + widget.options["data"]][value];

          print("ICONFILE" + iconFile);
          final Widget svgIcon = SvgPicture.asset(
              "assets/icons/pool/" + iconFile,
              color: Colors.black,
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
        choices.add(Container(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            selectedColor: Theme.of(context).accentColor,
            avatar: CircleAvatar(backgroundColor: Theme.of(context).primaryColor, child: getIcon(item,mpi)),
            label: Container(padding: EdgeInsets.all(5),child:Text(item, style: Theme.of(context).textTheme.headline6,)),
            selected: selectedChoice == item,
            onSelected: (selected) {
              setState(() {
                selectedChoice = item;
                BasicElementNotification(widget.options["data"], selectedChoice, BasicElementNotificationType.Data).dispatch(context);
                /*widget.onSelectionChanged(selectedChoice);*/
              });
            },
          ),
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
