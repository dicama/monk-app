import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';


class TextElement extends BasicElement {
  final String key = "Text";


  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return TextElementWidget(input, moduleId, BasicElement.getOptions(input, parentOptions: parentOptions), BasicElement.getStyle(input));
  }

}


class _TextElementState extends State<TextElementWidget> {

  var func;
  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
  }

  parseScriptMeta(String input) {

    if(widget.options.containsKey("mode") && widget.options["parent"].containsKey("mode"))
    {
      if(widget.options["mode"] != widget.options["parent"]["mode"])
      {
        func = (BuildContext context1) {return Container();};
        return;
      }
    }


    var stylo;
    print(context.toString());


      if(widget.options["text"].startsWith('\$'))
      {
        final address = widget.options["text"].substring(1);
        final innerstyle = widget.style["text"];
        func = (BuildContext context1) {
          if(widget.options["text"] == "h1")
          {
            stylo =  Theme.of(context1).textTheme.headline1;

          }
          else if(innerstyle=="h2") {
            stylo =  Theme.of(context1).textTheme.headline2;

          }
          else if(innerstyle=="h4") {
            stylo = Theme.of(context1).textTheme.headline4;

          }
          else if(innerstyle=="h5") {
            stylo = Theme.of(context1).textTheme.headline5;

          }
          else if(innerstyle=="h6") {
            stylo = Theme.of(context1).textTheme.headline6;

          }
          else {
            stylo = Theme.of(context1).textTheme.bodyText1;
          }
          return Text(AccessLayer().getString(widget.moduleId, address, defaultValue: "Unset: " + address), style: stylo);
        };
      }
      else
      {
        final inner = widget.options["text"];
        final innerstyle = widget.style["text"];
        func = (BuildContext context1) {
          if(innerstyle == "h1")
          {
            stylo =  Theme.of(context1).textTheme.headline1;

          }
          else if(innerstyle=="h2") {
            stylo =  Theme.of(context1).textTheme.headline2;

          }
          else if(innerstyle=="h4") {
            stylo = Theme.of(context1).textTheme.headline4;

          }
          else if(innerstyle=="h5") {
            stylo = Theme.of(context1).textTheme.headline5;

          }
          else if(innerstyle=="h6") {
            stylo = Theme.of(context1).textTheme.headline6;

          }
          else {
            stylo = Theme.of(context1).textTheme.bodyText1;
          }

          return Text(inner, style: stylo);
        };
      }
    }


  @override
  Widget build(BuildContext context) {
    return func(context);
  }

}


class TextElementWidget extends StatefulWidget {
  final Map options;
  final Map style;
  final String input;
  final String moduleId;

  TextElementWidget(this.input, this.moduleId, this.options,this.style);

  @override
  _TextElementState createState() => _TextElementState();


}
