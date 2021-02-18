import 'package:flutter/cupertino.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:monk/main.dart';

String name = AccessLayer().getData("GENERAL", "0&Name");
String age = AccessLayer().getData("GENERAL", "0&Alter");
String gender = AccessLayer().getData("GENERAL", "0&Geschlecht");
String dateOfDiagnose = AccessLayer().getData("GENERAL", "0&DatumDerDiagnose");
String diagnose = AccessLayer().getData("GENERAL", "0&Diagnose");


class PersonalView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PersonalState();
  }
}

class PersonalState extends State<PersonalView> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        title: new Text("Persönliche Informationen"),
      ),
      body: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              textAlign: TextAlign.left,
              initialValue: name,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: 'Name',
                icon: Icon(Icons.person),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: (String value) {
                setState(() {
                  name = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              textAlign: TextAlign.left,
              initialValue: age,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              decoration: InputDecoration(
                labelText: 'Alter',
                icon: Icon(Icons.cake),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onChanged: (String value) {
                if (value.length == 2) {
                  FocusScope.of(context).requestFocus(FocusNode());
                }
                setState(() {
                  age = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButtonFormField(
              value: diagnose,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                icon: Icon(Icons.people),
                labelText: 'Diagnose',
              ),
              elevation: 15,
              onChanged: (String newValue) {
                setState(() {
                  diagnose = newValue;
                });
              },
              items: <String>[
                'Keine Angabe',
                'Darmkrebs',
                'Brustkrebs',
                'Lungenkrebs',
                'Prostatakrebs'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DateTimePicker(
              initialValue: dateOfDiagnose,
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
              textAlign: TextAlign.left,
              calendarTitle: 'Datum der Diagnose',
              cancelText: 'Abbrechen',
              confirmText: 'Auswählen',
              fieldLabelText: 'Diagnose am',
              fieldHintText: 'Monat/Tag/Jahr',
              errorFormatText: 'Gebe ein korrektes Datum ein',
              errorInvalidText:
                  'Gebe ein Datum im korrekten Format an Monat/Tag/Jahr',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                icon: Icon(Icons.event),
                labelText: 'Datum der Diagnose',
              ),
              onChanged: (val) => dateOfDiagnose = val,
              onSaved: (val) => dateOfDiagnose = val,
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 5.0,
            children: <Widget>[
              /*reportList.forEach((item){
                       })*/
              ChoiceChip(
                label: Text("männlich"),
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                selectedColor: MyApp.getThemeData().buttonColor,
                selected: gender == "m",
                onSelected: (selected) {
                  setState(() {
                    gender = "m";
                  });
                },
              ),
              ChoiceChip(
                label: Text("weiblich"),
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                selectedColor: MyApp.getThemeData().buttonColor,
                selected: gender == "w",
                onSelected: (selected) {
                  setState(() {
                    gender = "w";
                  });
                },
              ),
              ChoiceChip(
                label: Text("diverse"),
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                selectedColor: MyApp.getThemeData().buttonColor,
                selected: gender == "d",
                onSelected: (selected) {
                  setState(() {
                    gender = "d";
                  });
                },
              ),
            ],
          ),
        ],

      ),
    );
  }
  void saveData() {
    //TODO General besprechen
    AccessLayer().setData("GENERAL", "0&Name", name);
    AccessLayer().setData("GENERAL", "0&Alter", age);
    AccessLayer().setData("GENERAL", "0&Geschlecht", gender);
    AccessLayer().setData("GENERAL", "0&DatumDerDiagnose", dateOfDiagnose);
    AccessLayer().setData("GENERAL", "0&Diagnose", diagnose);
  }
}
