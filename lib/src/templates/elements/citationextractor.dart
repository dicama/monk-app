import 'package:carousel_slider/carousel_slider.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class CitationExtractorElement extends BasicElement {
  final String key = "CitationExtractor";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    return CitationExtractorElementWidget(
        input, moduleId,
        BasicElement.getOptions(input, parentOptions: parentOptions),
        BasicElement.getStyle(input));
  }
}

class Citation {
  Citation(this.quote, this.name, this.date);

  final String quote;
  final String name;
  final String date;
}

class _CitationExtractorElementState
    extends State<CitationExtractorElementWidget> {
  var func;

  @override
  void initState() {
    super.initState();
    parseScriptMeta(widget.input);
  }

  Future<List<Citation>> getCitation() async {
    var fileDat =
        await BasicElement.getFileData(widget.options["citationFile"]);
    List<List<dynamic>> citationCsv =
        CsvToListConverter(fieldDelimiter: ";", eol: "\n").convert(fileDat);
    List<Citation> listCit = new List<Citation>();
    DateTime dat;
    if (AccessLayer().getData(widget.moduleId, widget.options["dateaddress"]) == null) {
      dat = DateTime.now().subtract(Duration(days: 1));
      AccessLayer().setData(widget.moduleId, widget.options["dateaddress"], dat.toIso8601String());
    } else {
      dat = DateTime.parse(AccessLayer().getData(widget.moduleId, widget.options["dateaddress"]));
    }
    dat = dat.subtract(Duration(
        hours: dat.hour,
        minutes: dat.minute,
        seconds: dat.second,
        milliseconds: dat.millisecond,
        microseconds: dat.microsecond));

    int maxCount = int.parse(widget.options["maxNumber"]);
    DateTime now = DateTime.now();

    int selectedCitation = now.difference(dat).inDays % citationCsv.length;

    int count = 0;

    for (var i = selectedCitation; i < citationCsv.length; i++) {
      if (count < maxCount) {
        count++;
        listCit.add(Citation("„" + citationCsv[i][0] + "”", citationCsv[i][1],
            citationCsv[i][2]));
      }
    }
    for (var i = 0; i < selectedCitation; i++) {
      if (count < maxCount) {
        count++;
        listCit.add(Citation("„" + citationCsv[i][0] + "”", citationCsv[i][1],
            citationCsv[i][2]));
      }
    }

    /*print("length")*/;
    /*print(citationCsv[0].length)*/;
    return listCit;
  }

  List<Widget> convertCitationsToWidgets(List<Citation> cities) {
    List<Widget> listWidg = List<Widget>();

    cities.forEach((element) {
      listWidg.add(Wrap(children: [
        Container(
            width: MediaQuery.of(context).size.width,
            child: Text(element.quote,
                style: Theme.of(context).textTheme.subtitle1),
            padding: EdgeInsets.all(16)),
        Container(
            alignment: Alignment.bottomRight,
            child: Text(element.name,
                style: Theme.of(context).textTheme.subtitle2),
            padding: EdgeInsets.all(16)),
        Text(element.date)
      ]));
    });

    return listWidg;
  }

  parseScriptMeta(String input) {
    if (widget.options.containsKey("mode") &&
        widget.options["parent"].containsKey("mode")) {
      if (widget.options["mode"] != widget.options["parent"]["mode"]) {
        func = (BuildContext context1) {
          return Container();
        };
        return;
      }
    }
    func = (BuildContext context1) {
      return FutureBuilder<List<Citation>>(
          future: getCitation(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Citation>> snapshot) {
            List<Citation> cit;
            List<Widget> children;
            var alignment = MainAxisAlignment.start;
            if (snapshot.hasData) {
              cit = snapshot.data;
              children = <Widget>[
                CarouselSlider(
                    items: convertCitationsToWidgets(cit),
                    options: CarouselOptions(
                      height: double.parse(widget.options["height"]),
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      viewportFraction: 1.0,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 10),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    )),
              ];
            } else if (snapshot.hasError) {
              cit = [Citation("Error", "Your Module", "")];
              children = <Widget>[Text(cit[0].quote), Text(cit[0].name)];
            } else {
              alignment = MainAxisAlignment.center;
              children = <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Lade Module...'),
                )
              ];
            }
            return Center(
                child: Column(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ));
          });
    };

    return func;
  }

  @override
  Widget build(BuildContext context) {
    return func(context);
  }
}

class CitationExtractorElementWidget extends StatefulWidget {
  final Map options;
  final Map style;
  final String input;
  final String moduleId;

  CitationExtractorElementWidget(this.input, this.moduleId, this.options, this.style);

  @override
  _CitationExtractorElementState createState() =>
      _CitationExtractorElementState();
}
