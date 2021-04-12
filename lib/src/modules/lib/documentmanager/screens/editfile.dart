import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monk/src/customwidgets/addabletags.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:path/path.dart' show basename;

class EditFileScreen extends StatefulWidget {
  final FileSysElement element;

  const EditFileScreen(this.element);

   @override
  EditFileScreenState createState() => EditFileScreenState();
}

class EditFileScreenState extends State<EditFileScreen> {
  File imageFile;
  List<String> selectedTags = List();
  TextEditingController folderController =
      TextEditingController(text: "New Folder");
  TextEditingController _filenameController = TextEditingController(
      text: DateFormat()
              .add_yMd()
              .add_Hms()
              .format(DateTime.now())
              .replaceAll("/", "_")
              .replaceAll(" ", "_")
              .replaceAll(":", "_") +
          ".pdf");
  FileSysDirectory currentDir;

  @override
  Future<void> initState() {
    super.initState();
    // To display the current output from the Camera,
      _filenameController.text = basename(widget.element.name);
       currentDir = EncryptedFS().getRoot();
       selectedTags = widget.element.tags;
    // Next, initialize the controller. This returns a Future.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Save in Monk'),
            actions: [IconButton(icon: Icon(Icons.drive_file_rename_outline))]),
        bottomNavigationBar: BottomAppBar(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    child: Text("ABBRECHEN"),
                    onPressed: () async {
                      Navigator.pop(context);
                    })
              ,
                FlatButton(
                    child: Text("SPEICHERN"),
                    onPressed: () async {
                      widget.element.edit(_filenameController.text, selectedTags);
                      Navigator.pop(context);
                    })
              ]),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _filenameController,
              )),
           Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text("Schlüsselwörter auswählen",
                  style: Theme.of(context).textTheme.subtitle1),
              alignment: Alignment.centerLeft),
          Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AddableTagsWidget(
                widget.element.tags + EncryptedFS().getTopKTags(5, excludeTags: widget.element.tags),
                selectedList: widget.element.tags,
                onSelection: (sel) {
                  selectedTags = sel;
                  print(selectedTags);
                },
              )),
        ]))
        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializin
        );
  }
}
