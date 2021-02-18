import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:monk/src/customwidgets/fileexplorer.dart';
import 'package:monk/src/customwidgets/fileexplorerspecial.dart';
import 'package:monk/src/customwidgets/filepreview.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

class _FavoritesWidgetState extends State<FavoritesWidget> {
  var groupVal = -1;
  var func;
  bool isCompact = false;

  @override
  void initState() {
    super.initState();

    // Get a specific camera from the list of available cameras.
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
        height: 70,
        padding: EdgeInsets.all(12),
        child: TypeAheadField(
            hideOnEmpty: true,
            textFieldConfiguration: TextFieldConfiguration(
                autofocus: false,
                style:
                    DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(8, 3, 0, 0),
                    hintText: "Suche in Favoriten",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search))),
            suggestionsCallback: (pattern) async {
              if (pattern == "") {
                return [];
              } else {
                return EncryptedFS()
                    .findFiles(pattern.toLowerCase(), isFavorite: true);
              }
            },
            itemBuilder: (context, suggestion) {
              return FilePreviewWidget(suggestion, isListElement: true);
            },
            onSuggestionSelected: (suggestion) {
              /*Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductPage(product: suggestion)
        ));*/
            }),
      ),
      Row(children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Text("Favoriten".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(color: Colors.black)))),
        ),
        IconButton(
            icon:
                isCompact ? Icon(Icons.view_agenda_outlined) : Icon(Icons.list),
            onPressed: () {
              setState(() {
                isCompact = !isCompact;
              });
            })
      ]),
      Container(
          child: FileExplorerSpecWidget.forFavorites(
        isCompact: isCompact,
      ))
    ]));
  }
}

class FavoritesWidget extends StatefulWidget {
  @override
  _FavoritesWidgetState createState() => _FavoritesWidgetState();
}
