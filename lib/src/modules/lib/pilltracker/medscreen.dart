import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monk/src/customwidgets/addabletags.dart';
import 'package:monk/src/modules/lib/pilltracker/models.dart';

class MedScreen extends StatefulWidget {
  final Medication editMed;
  final List<Medication> medicationLib;
  const MedScreen({this.editMed, this.medicationLib});

  @override
  MedScreenState createState() => MedScreenState();
}

class MedScreenState extends State<MedScreen> {
  Medication myMed;

  int consumptionsPerCycle = 3;
  List<int> consumptionTimes = [16, 24, 36, 38, 42, 42, 42, 42, 42, 42];
  List<int> consumptionDay = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<double> consumptionAmounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
  List<String> initalCategories = ["Allgemein", "Schmerzmittel", "Diuretika"];
  List<TextEditingController> consumptionAmountsCtrl = [
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1"),
    TextEditingController(text: "1")
  ];

  TextEditingController consumptionAmountCtrl =
      TextEditingController(text: "1");

  MedicationUnits consumptionUnits = MedicationUnits.items;
  double consumptionAmout = 1;

  TextEditingController _initalUnitsController =
      TextEditingController(text: "25");
  TextEditingController _nameController = TextEditingController(text: "");
  TextEditingController _agentController = TextEditingController(text: "");
  TextEditingController _notesController = TextEditingController(text: "");

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return int.tryParse(result) != null;
  }

  checkIfAllVisibleAreTheSameOrAsignStar() {
    double val;
    bool constant = true;
    for (int i = 0; i < consumptionsPerCycle; i++) {
      if (val == null) {
        val = consumptionAmounts[i];
      } else {
        if (val != consumptionAmounts[i]) {
          constant = false;
          break;
        }
      }
    }
    if (constant) {
      consumptionAmountCtrl.text = consumptionAmounts[0].toString();
    } else {
      consumptionAmountCtrl.text = "*";
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.editMed == null) {
      myMed = Medication("", "", [], "", 0, 0);
      myMed.type = MedicationType.pill;
      myMed.unitsOfUnits = MedicationUnits.items;
      myMed.category = "Allgemein";
      myMed.initalUnits = 25;
      myMed.consumptionCycle = MedicationCycle.day;
    } else {
      myMed = Medication("", "", [], "", 0, 0);

      _agentController.text = widget.editMed.agent;
      _nameController.text = widget.editMed.name;
      consumptionsPerCycle = widget.editMed.consumptionTimes.length;
      _notesController.text = widget.editMed.notes;
      _initalUnitsController.text = widget.editMed.initalUnits.toString();
      myMed.initalUnits = widget.editMed.initalUnits;
      myMed.notes = widget.editMed.notes;
      myMed.category = widget.editMed.category;
      myMed.unitsOfUnits = widget.editMed.unitsOfUnits;
      myMed.isAsNeeded = widget.editMed.isAsNeeded;
      myMed.type = widget.editMed.type;
      myMed.remind = widget.editMed.remind;
      myMed.consumptionCycle = widget.editMed.consumptionCycle;
      myMed.agent = widget.editMed.agent;
      myMed.name = widget.editMed.name;
      int count = 0;

      for (MedicationTime mc in widget.editMed.consumptionTimes) {
        consumptionTimes[count] =
            ((mc.consumptionTime % (48 * 30)) / 30).floor();
        consumptionDay[count] = (mc.consumptionTime / (48 * 30)).floor();
        consumptionAmounts[count] = mc.amount;
        consumptionAmountsCtrl[count].text = mc.amount.toString();
        consumptionUnits = mc.units;
        count++;
      }
      checkIfAllVisibleAreTheSameOrAsignStar();
    }

    if (!initalCategories.contains(myMed.category)) {
      initalCategories.insert(0, myMed.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: take care of full input validation

    return Scaffold(
      appBar: AppBar(
        title: Text('Neues Medikament'),
      ),
      bottomNavigationBar: BottomAppBar(),
      body: SingleChildScrollView(
          child: Column(children: [
        Row(children: [
          Expanded(
              child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 0, 4),
                  color: Theme.of(context).accentColor.withOpacity(0.1),
                  child: Text("Informationen zu Medikamenten".toUpperCase(),
                      style: Theme.of(context).textTheme.overline)))
        ]),
        Container(
            padding: EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    labelText: "Handelsname",
                    hintText: 'Handelsname '),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _agentController,
                decoration: InputDecoration(
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    labelText: "Wirkstoff(e)",
                    hintText: 'Wirkstoff(e) mit Menge angeben'),
              ),
              SizedBox(height: 12),
              /*Row(children: [
                Expanded(
                    child: Text("Wirkstoffmenge".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Container(
                    width: 80,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                        onSubmitted: (val) {},
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          isDense: true,
                          hintText: '100',
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        ))),
                Container(
                    width: 70,
                    child: DropdownButton<MedicationAgentUnits>(
                        value: agentUnits,
                        items: MedicationAgentUnits.values
                            .map<DropdownMenuItem<MedicationAgentUnits>>(
                                (MedicationAgentUnits value1) {
                          return DropdownMenuItem<MedicationAgentUnits>(
                            value: value1,
                            child: Text(
                                MedicationAgentUnitsStringsDE[value1.index]),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            agentUnits = val;
                          });
                        }))
              ]),*/
              Row(children: [
                Expanded(
                    child: Text("Darreichungsform".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Container(
                    width: 100,
                    child: DropdownButton<MedicationType>(
                        value: myMed.type,
                        items: MedicationType.values
                            .map<DropdownMenuItem<MedicationType>>(
                                (MedicationType value) {
                          return DropdownMenuItem<MedicationType>(
                            value: value,
                            child: Text(MedicationTypeStringsDE[value.index]
                                .toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            myMed.type = val;
                          });
                        }))
              ]),
              Row(children: [
                Expanded(
                    child: Text("Inhalt".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Container(
                    width: 70,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                        controller: _initalUnitsController,
                        textAlign: TextAlign.end,
                        onChanged: (val) {
                          myMed.initalUnits = double.parse(val);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+[\.\,]?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          isDense: true,
                          hintText: '100',
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        ))),
                Container(
                    width: 95,
                    child: DropdownButton<MedicationUnits>(
                        value: myMed.unitsOfUnits,
                        items: MedicationUnits.values
                            .map<DropdownMenuItem<MedicationUnits>>(
                                (MedicationUnits value) {
                          return DropdownMenuItem<MedicationUnits>(
                            value: value,
                            child: Text(MedicationUnitsStringsDE[value.index]
                                .toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            myMed.unitsOfUnits = val;
                          });
                        }))
              ])
            ])),
        SizedBox(height: 4),
        Row(children: [
          Expanded(
              child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 0, 4),
                  color: Theme.of(context).accentColor.withOpacity(0.1),
                  child: Text("Einahme Informationen".toUpperCase(),
                      style: Theme.of(context).textTheme.overline)))
        ]),
        Container(
            padding: EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(
                    child: Text("BEDARFSMEDIKATION".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Switch(
                    value: myMed.isAsNeeded,
                    onChanged: (value) {
                      setState(() {
                        myMed.isAsNeeded = value;
                        if (myMed.isAsNeeded == true) {
                          consumptionsPerCycle = 0;
                        }
                      });
                    })
              ]),
              /*myMed.isAsNeeded? Text("Wenn es sich um eine reine Bedarfsmedikation handelt, setze die regelmäßigen Einnahmen auf 0.") : Container(),*/
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Text("Menge pro Einnahme".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Container(
                    width: 70,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+[\.\,]?\d{0,2}')),
                        ],
                        controller: consumptionAmountCtrl,
                        onChanged: (val) {
                          double parsedVal = double.parse(val);
                          consumptionAmout = parsedVal;
                          consumptionAmounts.forEach((element) {
                            element = parsedVal;
                          });
                          consumptionAmountsCtrl.forEach((element) {
                            element.text = val;
                          });
                          setState(() {});
                        },
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          isDense: true,
                          hintText: 'Wert',
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        ))),
                Container(
                    width: 95,
                    child: DropdownButton<MedicationUnits>(
                        value: consumptionUnits,
                        items: MedicationUnits.values
                            .map<DropdownMenuItem<MedicationUnits>>(
                                (MedicationUnits value) {
                          return DropdownMenuItem<MedicationUnits>(
                            value: value,
                            child: Text(MedicationUnitsStringsDE[value.index]
                                .toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            consumptionUnits = val;
                          });
                        }))
              ]),
              Row(children: [
                Expanded(
                    child: Text("Anzahl der Einnahmen pro".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Container(
                    width: 106,
                    padding: EdgeInsets.only(right: 12),
                    child: DropdownButton<MedicationCycle>(
                        value: myMed.consumptionCycle,
                        items: MedicationCycle.values
                            .map<DropdownMenuItem<MedicationCycle>>(
                                (MedicationCycle value) {
                          return DropdownMenuItem<MedicationCycle>(
                            value: value,
                            child: SizedBox(
                                width: 66,
                                child: Text(
                                    MedicationCycleStringsDE[value.index]
                                        .toUpperCase(),
                                    textAlign: TextAlign.center)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          myMed.consumptionCycle = val;
                          if (myMed.consumptionCycle == MedicationCycle.day) {
                            for (int n = 0; n < consumptionDay.length; n++) {
                              consumptionDay[n] = 0;
                            }
                          }
                          setState(() {});
                        })),
                Container(
                    width: 54,
                    child: DropdownButton<int>(
                        value: consumptionsPerCycle,
                        items: List<int>.generate(10, (i) => i)
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: SizedBox(
                                width: 26,
                                child:
                                    Text("$value", textAlign: TextAlign.end)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            consumptionsPerCycle = val;
                          });
                        })),
              ]),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: consumptionsPerCycle,
                  itemBuilder: (context, index) {
                    return Row(children: [
                      Expanded(
                          child: Text("Einnahme ${index + 1}".toUpperCase(),
                              style: Theme.of(context).textTheme.button)),
                      Container(
                          width: 70,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                              controller: consumptionAmountsCtrl[index],
                              onChanged: (val) {
                                consumptionAmounts[index] = double.parse(val);
                                checkIfAllVisibleAreTheSameOrAsignStar();
                              },
                              textAlign: TextAlign.end,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+[\.\,]?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                isDense: true,
                                hintText: 'Wert',
                                border: new OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                              ))),
                      Container(
                          width: 45,
                          height: 15,
                          child: FittedBox(
                            child: Text(
                                MedicationUnitsStringsDE[consumptionUnits.index]
                                    .toUpperCase()),
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          )),
                      SizedBox(width: 8),
                      myMed.consumptionCycle == MedicationCycle.week
                          ? Container(
                              width: 49,
                              child: DropdownButton<int>(
                                  value: consumptionDay[index],
                                  items: List<int>.generate(7, (i) => i)
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                          DayOfWeekShortStringsDE[value]
                                              .toUpperCase(),
                                          textAlign: TextAlign.end),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      consumptionDay[index] = val;
                                    });
                                  }))
                          : Container(),
                      Container(
                          width: 76,
                          child: DropdownButton<int>(
                              value: consumptionTimes[index],
                              items: List<int>.generate(48, (i) => i)
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: SizedBox(
                                      width: 45,
                                      child: Text(
                                          "${(value / 2).floor()}" +
                                              ((value % 2 == 0)
                                                  ? ":00"
                                                  : ":30"),
                                          textAlign: TextAlign.end)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  consumptionTimes[index] = val;
                                });
                              }))
                    ]);
                  }),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Text("KATEGORIE".toUpperCase(),
                        style: Theme.of(context).textTheme.button))
              ]),
              AddableTagsWidget(
                initalCategories,
                selectedList: [myMed.category],
                singleSelect: true,
                forceLowerCase: false,
                onSelection: (val) {
                  if (val.isNotEmpty) {
                    myMed.category = val[0];
                  } else {
                    myMed.category = "";
                  }
                },
              ),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Text("HINWEISE".toUpperCase(),
                        style: Theme.of(context).textTheme.button))
              ]),
              SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          isDense: true,
                          hintText: 'Notizen',
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        )))
              ]),
              Row(children: [
                Expanded(
                    child: Text("Erinnerungen erhalten".toUpperCase(),
                        style: Theme.of(context).textTheme.button)),
                Switch(
                    value: myMed.remind,
                    onChanged: (value) {
                      setState(() {
                        myMed.remind = value;
                      });
                    })
              ])
            ])),
        Row(children: [
          Expanded(
              child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  color: Theme.of(context).accentColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      FlatButton(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            if (widget.editMed == null) {
                              myMed.name = _nameController.text;
                              myMed.agent = _agentController.text;
                              myMed.notes = _notesController.text;
                              myMed.availableUnits = myMed.initalUnits;
                              myMed.consumptionTimes = [];
                              for (int n = 0; n < consumptionsPerCycle; n++) {
                                myMed.consumptionTimes.add(MedicationTime(
                                    consumptionTimes[n] * 30 +
                                        48 * 30 * consumptionDay[n],
                                    consumptionAmounts[n],
                                    consumptionUnits));
                              }

                              Navigator.pop(context, myMed);
                            } else {
                              widget.editMed.name = _nameController.text;
                              widget.editMed.agent = _agentController.text;
                              widget.editMed.notes = _notesController.text;
                              widget.editMed.consumptionCycle =
                                  myMed.consumptionCycle;
                              widget.editMed.remind = myMed.remind;
                              widget.editMed.isAsNeeded = myMed.isAsNeeded;
                              widget.editMed.type = myMed.type;
                              widget.editMed.category = myMed.category;
                              widget.editMed.unitsOfUnits = myMed.unitsOfUnits;
                              widget.editMed.initalUnits = myMed.initalUnits;
                              widget.editMed.consumptionTimes = [];
                              for (int n = 0; n < consumptionsPerCycle; n++) {
                                widget.editMed.consumptionTimes.add(
                                    MedicationTime(
                                        consumptionTimes[n] * 30 +
                                            48 * 30 * consumptionDay[n],
                                        consumptionAmounts[n],
                                        consumptionUnits));
                              }

                              Navigator.pop(context);
                            }
                          },
                          child: widget.editMed == null
                              ? Text("Medikament speichern".toUpperCase())
                              : Text("Speichern".toUpperCase()),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                  color: Theme.of(context).accentColor))),
                      SizedBox(height: 8),
                      FlatButton(
                          color: Colors.transparent,
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          child: Text("Abbrechen".toUpperCase(),
                              style: TextStyle(color: Colors.grey)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.grey))),
                      widget.editMed != null
                          ? SizedBox(height: 8)
                          : Container(),
                      widget.editMed != null
                          ? FlatButton(
                              color: Colors.transparent,
                              onPressed: () {


                                // show the dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    Widget cancelButton = FlatButton(
                                      child: Text("Abbrechen".toUpperCase()),
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                    );

                                    // set up the button
                                    Widget okButton = FlatButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    );

                                    // set up the AlertDialog
                                    AlertDialog alert = AlertDialog(
                                      title: Text("Medikament Löschen"),
                                      content: Text(
                                          "Willst Du das Medikament wirklich löschen?"),
                                      actions: [
                                        cancelButton,okButton
                                      ],
                                    );
                                    return alert;
                                  },
                                ).then((isAccepted) {
                                  if (isAccepted) {
                                      widget.medicationLib.remove(widget.editMed);
                                    Navigator.pop(context, null);
                                  }
                                });
                              },
                              child: Text("Löschen".toUpperCase(),
                                  style: TextStyle(color: Colors.grey)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.grey)))
                          : Container(),
                    ],
                  )))
        ])
      ])),
    );

    // Wait until the controller is initialized before displaying the
    // camera preview. Use a FutureBuilder to display a loading spinner
    // until the controller has finished initializin
  }
}
