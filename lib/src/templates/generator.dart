import 'package:flutter/widgets.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:monk/src/templates/elements/buttonelement.dart';
import 'package:monk/src/templates/elements/chartelement.dart';
import 'package:monk/src/templates/elements/chipinputelement.dart';
import 'package:monk/src/templates/elements/citationextractor.dart';
import 'package:monk/src/templates/elements/colorpickerelement.dart';
import 'package:monk/src/templates/elements/datetimeelement.dart';
import 'package:monk/src/templates/elements/inputelement.dart';
import 'package:monk/src/templates/elements/linechartelement.dart';
import 'package:monk/src/templates/elements/numberpickerelement.dart';
import 'package:monk/src/templates/elements/selectchipelement.dart';
import 'package:monk/src/templates/elements/selecttileelement.dart';
import 'package:monk/src/templates/elements/textelement.dart';
import 'package:monk/src/templates/elements/timeserieslistelement.dart';
import 'package:monk/src/templates/elements/timeseriesstatisticselement.dart';
import 'package:monk/src/templates/elements/webviewtelement.dart';

import 'elements/imageelement.dart';
import 'elements/singlechoiceelement.dart';
import 'elements/stackedchartelement.dart';

class WidgetGenerator {
  static List<BasicElement> registered = [
    InputElement(),
    TextElement(),
    SingleChoiceElement(),
    DateTimeElement(),
    ChartElement(),
    WebViewElement(),
    ColorPickerElement(),
    SelectChipElement(),
    ButtonElement(),
    TimeSeriesListElement(),
    TimeSeriesStatisticsElement(),
    ChipInputElement(),
    SelectTileElement(),
    CitationExtractorElement(),
    NumberPickerElement(),
    LineChartElement(),
    ImageElement(),
    StackedChartElement()
  ];

  static List<Widget> parseString(
      String input, Module parent, String moduleId) {
    List<String> tokens = input.split("\n");
    List<Widget> wigs = List<Widget>();
    tokens.forEach((token) {
      registered.forEach((element) {
        if (token.startsWith(element.key)) {
          wigs.add(element.parseScript(token, parent, moduleId));
        }
      });
    });

    return wigs;
  }

  static List<Widget> parseStringMeta(
      String input, Module parent, String moduleId,
      {Map parentOptions}) {
    //print("widg gen");
    List<String> tokens = input.split("\n");
    List<Widget> wigs = List<Widget>();
    tokens.forEach((token) {
      registered.forEach((element) {
        if (token.startsWith(element.key)) {
          //print(token);
          wigs.add(element.parseScript(token, parent, moduleId,
              parentOptions: parentOptions));
        }
      });
    });
    //print("widg done");
    return wigs;
  }
}
