import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class ImageElement extends BasicElement {
  final String key = "Image";

  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions}) {
    Map opts = BasicElement.getOptions(input);
    double height = double.parse(opts["height"]);
    print("adding image");
    if (opts.containsKey("asset")) {
      return Row(children: [
        Expanded(
            child: Container(
                height: height,
                child: Image.asset("assets/res/pool/" + opts["asset"], fit: BoxFit.cover)))
      ]);
    } else {
      return Row(children: [
        Expanded(
            child: Container(
                height: height,
                child: Image.network(opts["url"], fit: BoxFit.cover)))
      ]);
    }
  }
}
