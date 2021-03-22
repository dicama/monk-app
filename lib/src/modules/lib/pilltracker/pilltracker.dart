import 'dart:io';

import 'package:camera/camera.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/savefile.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/takepicture.dart';

import 'package:monk/src/modules/lib/pilltracker/pilltrackerwidget.dart';
import 'package:monk/src/pdf_templates/pdfgenerator.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:monk/tools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import '../../basicmodule.dart';
import 'medscreen.dart';
import 'models.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class MedicationSlotSet {
  List<Map<MedicationTime, Medication>> medicationSlots = List();
  List<int> medicationSlotsNumber = List();
  List<int> medicationSlotsTaken = List();
}

class MedicationManager {
  static const List<int> startTimes = [5, 12, 17, 22];
  List<List<Medication>> consumptionTimeSlots;
  List<Medication> asNeededMeds;
  List<Medication> medicationLib = [];

  MedicationSlotSet slotSet = MedicationSlotSet();

  Map<String, List<Medication>> medicationCategories;

  load() {
    var tempMedLib = AccessLayer()
        .getModuleDataString(PillTrackerModule.pillTrackerId, "medicationLib");
    if (tempMedLib == null) {
      medicationLib = [];
      saveMedicationLib();
    } else {
      medicationLib = [];

      tempMedLib.forEach((var ele) {
        medicationLib.add(Medication.fromJson(ele));
      });
    }
  }

  List<pw.Widget> makeReport(pw.Context context) {
    DateTime lastDate = getFirstMedication();
    lastDate = lastDate.subtract(Duration(
        hours: lastDate.hour,
        minutes: lastDate.minute,
        seconds: lastDate.second,
        milliseconds: lastDate.millisecond,
        microseconds: lastDate.microsecond));

    DateTime currentDate = DateTime.now();
    List<pw.Widget> widgs = List();
    widgs.add(
        pw.Text("Modul: Pillentracker", style: pw.TextStyle(fontSize: 20)));
    widgs.add(pw.SizedBox(width: 10, height: 25));
    widgs.add(pw.Text("Medikamentenhistorie",
        style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)));

    while (currentDate.isAfter(lastDate)) {
      bool missed = false;
      bool needed = false;

      List<List<String>> stringList = List();
      MedicationSlotSet slots = buildSlotsForDay(currentDate);
      List<String> titles = [
        "Medikation",
        "Morgens",
        "Mittags",
        "Abends",
        "Nachts"
      ];

      Map<Medication, List<String>> medList = Map();

      stringList.add(titles);

      for (int i = 0; i < slots.medicationSlots.length; i++) {
        for (MedicationTime mt in slots.medicationSlots[i].keys) {
          if (!medList.keys.contains(slots.medicationSlots[i][mt])) {
            medList[slots.medicationSlots[i][mt]] = [
              slots.medicationSlots[i][mt].name,
              "",
              "",
              "",
              ""
            ];
          }

          MedicationConsumption mc = slots.medicationSlots[i][mt]
              .getFittingConsumptionOnDay(mt, currentDate);

          if (mc != null) {
            medList[slots.medicationSlots[i][mt]]
                [i + 1] = medList[slots.medicationSlots[i][mt]]
                    [i + 1] +
                "${mc.amount}\u{2009}${MedicationUnitsShortStringsDE[mt.units.index]} @${DateFormat.Hm().format(mc.consumptionTimeActually)}  ";
          } else {
            missed = true;
            medList[slots.medicationSlots[i][mt]][i + 1] =
                medList[slots.medicationSlots[i][mt]][i + 1] +
                    " X@" +
                    mt.toHours();
          }
        }
      }

      List<Medication> lKeys = medList.keys.toList();

      lKeys.sort((Medication a, Medication b) {
        return a.name.compareTo(b.name);
      });

      lKeys.forEach((element) {
        stringList.add(medList[element]);
      });

      List<List<String>> asNeededList = List();
      List<String> asNeedTitles = [
        "Medikation",
        "Bedarfseinnahmen",
      ];
      asNeededList.add(asNeedTitles);
      asNeededMeds.forEach((element) {
        asNeededList.add([element.name, ""]);
        element.getAsNeededConsumptionOnDay(currentDate).forEach((mc) {
          asNeededList.last[1] = asNeededList.last[1] +
              "${mc.amount}\u{2009}${MedicationUnitsShortStringsDE[element.unitsOfUnits.index]} @${DateFormat.Hm().format(mc.consumptionTimeActually)}  ";
          needed = true;
        });
      });

      widgs.add(pw.SizedBox(width: 10, height: 25));
      widgs.add(pw.Row(children: [
        pw.Text(DateFormat().addPattern("dd.MM.yy").format(currentDate),
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(missed ? "  MEDIKATION VERPASST" : "",
            style: pw.TextStyle(
                fontSize: 16,
                color: PdfColor.fromInt(Color.fromRGBO(255, 0, 0, 1.0).value))),
        pw.Text(needed ? "  BEDARFSMED" : "",
            style: pw.TextStyle(
                fontSize: 16, color: PdfColor.fromInt(Colors.blueAccent.value)))
      ]));
      widgs.add(pw.SizedBox(width: 10, height: 10));
      widgs.add(pw.Table.fromTextArray(context: context, data: stringList));
      if (asNeededList.length > 1) {
        widgs.add(pw.SizedBox(width: 10, height: 10));
        widgs.add(pw.Text("Bedarfsmedikation"));
        widgs.add(pw.SizedBox(width: 5, height: 10));

        widgs.add(pw.Table.fromTextArray(context: context, data: asNeededList));
      }
      /*cellStyle: pw.TextStyle(color: PdfColor.fromInt(Colors.grey[800].value))*/
      currentDate = currentDate.subtract(Duration(days: 1));
      print(stringList);
    }

    /*
    this.moduleIdentifier = moduleIdentifier;
    Map opts = BasicPDFElement.getOptions(input);
    final out = pw.Text(opts["text"]);*/

    return widgs;
  }

  DateTime getFirstMedication() {
    DateTime first = DateTime.now();
    medicationLib.forEach((element) {
      element.consumptionHistory.forEach((con) {
        if (con.consumptionTimeActually.isBefore(first)) {
          first = con.consumptionTimeActually;
        }
      });
    });

    return first;
  }

  saveMedicationLib() {
    List<Map> tempArray = [];
    medicationLib.forEach((element) {
      tempArray.add(element.toJson());
    });
    AccessLayer().setModuleData(
        PillTrackerModule.pillTrackerId, "medicationLib", tempArray);
  }

  buildSlots() {
    slotSet.medicationSlots = List();
    slotSet.medicationSlotsNumber = List();
    slotSet.medicationSlotsTaken = List();
    startTimes.forEach((st) {
      slotSet.medicationSlots.add(Map());
    });

    // add on demand entry
    asNeededMeds = [];

    medicationLib.forEach((med) {
      bool medCycWeek = false;
      if (med.consumptionCycle == MedicationCycle.week) {
        medCycWeek = true;
      }

      for (MedicationTime medTime in med.consumptionTimes) {
        var consumptionTimeInHours = medTime.consumptionTime / 60;

        if (medCycWeek) {
          consumptionTimeInHours =
              consumptionTimeInHours - ((DateTime.now().weekday - 1) * 24);
        }

        if (consumptionTimeInHours >= 0 &&
            consumptionTimeInHours < startTimes.first) {
          slotSet.medicationSlots[startTimes.length - 1][medTime] =
              med; // add to last regular slot
          continue;
        }

        if (consumptionTimeInHours >= startTimes.last &&
            consumptionTimeInHours < 24) {
          slotSet.medicationSlots[startTimes.length - 1][medTime] =
              med; // add to last regular slot
          continue;
        }

        for (var i = 0; i < startTimes.length - 1; i++) {
          if (consumptionTimeInHours < startTimes[i + 1] &&
              consumptionTimeInHours >= startTimes[i]) {
            slotSet.medicationSlots[i][medTime] = med;
            break;
          }
        }
      }

      if (med.isAsNeeded) {
        asNeededMeds.add(med);
      }
    });
    slotSet.medicationSlots.forEach((element) {
      slotSet.medicationSlotsNumber.add(element.length);
      var takenMeds = 0;
      element.forEach((key, value) {
        if (value.getFittingConsumptionTimeToday(key) != null) {
          takenMeds++;
        }
      });
      slotSet.medicationSlotsTaken.add(takenMeds);
    });
  }

  MedicationSlotSet buildSlotsForDay(DateTime day) {
    MedicationSlotSet daySlotSet = MedicationSlotSet();

    startTimes.forEach((st) {
      daySlotSet.medicationSlots.add(Map());
    });

    // add on demand entry
    medicationLib.forEach((med) {
      bool medCycWeek = false;
      if (med.consumptionCycle == MedicationCycle.week) {
        medCycWeek = true;
      }

      for (MedicationTime medTime in med.consumptionTimes) {
        var consumptionTimeInHours = medTime.consumptionTime / 60;

        if (medCycWeek) {
          consumptionTimeInHours =
              consumptionTimeInHours - ((day.weekday - 1) * 24);
        }

        if (consumptionTimeInHours >= 0 &&
            consumptionTimeInHours < startTimes.first) {
          daySlotSet.medicationSlots[startTimes.length - 1][medTime] =
              med; // add to last regular slot
          continue;
        }

        if (consumptionTimeInHours >= startTimes.last &&
            consumptionTimeInHours < 24) {
          daySlotSet.medicationSlots[startTimes.length - 1][medTime] =
              med; // add to last regular slot
          continue;
        }

        for (var i = 0; i < startTimes.length - 1; i++) {
          if (consumptionTimeInHours < startTimes[i + 1] &&
              consumptionTimeInHours >= startTimes[i]) {
            daySlotSet.medicationSlots[i][medTime] = med;
            break;
          }
        }
      }
    });
    daySlotSet.medicationSlots.forEach((element) {
      daySlotSet.medicationSlotsNumber.add(element.length);
      var takenMeds = 0;
      element.forEach((key, value) {
        if (value.getFittingConsumptionTimeToday(key) != null) {
          takenMeds++;
        }
      });
      daySlotSet.medicationSlotsTaken.add(takenMeds);
    });

    return daySlotSet;
  }

  buildCategories() {
    medicationCategories = Map();

    medicationLib.forEach((med) {
      if (medicationCategories.keys.contains(med.category)) {
        medicationCategories[med.category].add(med);
      } else {
        medicationCategories[med.category] = [med];
      }
    });
  }

  Map<String, double> getSmallestRatioPerCategory() {
    Map<String, double> smallestRatio = Map();
    medicationCategories.forEach((key, List<Medication> value) {
      double ratio = 1;
      value.forEach((element) {
        if ((element.availableUnits / element.initalUnits) < ratio) {
          ratio = (element.availableUnits / element.initalUnits);
        }
      });
      smallestRatio[key] = ratio;
    });

    return smallestRatio;
  }

  DateTime getNextConsumption() {
    int todaysMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
    DateTime startday = DateTime.now();
    startday = startday.subtract(Duration(
        hours: startday.hour,
        minutes: startday.minute,
        seconds: startday.second,
        milliseconds: startday.millisecond,
        microseconds: startday.microsecond));
    List<int> criticals = List();
    for (Map element in slotSet.medicationSlots) {
      var timeList = element.keys.toList()
        ..sort((a, b) {
          return (a.consumptionTime - b.consumptionTime);
        });
      for (MedicationTime mt in timeList) {
        if (mt.consumptionTime % (60 * 24) > todaysMinutes) {
          var minutesToday = mt.consumptionTime % (60 * 24);

          startday = startday.add(Duration(
              hours: (minutesToday / 60).floor(), minutes: minutesToday % 60));

          return startday;
        }
      }
    }

    return null;
  }

  List<int> getSlotStates() {
    buildSlots();
    int todaysMinutes = DateTime.now().hour * 60 + DateTime.now().minute;

    List<int> criticals = List();
    slotSet.medicationSlots.forEach((element) {
      var criticality = 0;
      element.forEach((key, value) {
        if (key.consumptionTime % (60 * 24) < todaysMinutes) {
          if (value.wasTakenToday(key)) {
            if (criticality < 1) {
              criticality = 1;
            }
          } else {
            if (key.consumptionTime % (60 * 24) + 30 < todaysMinutes) {
              if (criticality < 3) {
                criticality = 3;
              }
            } else {
              if (criticality < 2) {
                criticality = 2;
              }
            }
          }
        }
      });
      criticals.add(criticality);
    });

    return criticals;
  }

  bool getForgotten() {
    int todaysMinutes = DateTime.now().hour * 60 + DateTime.now().minute;

    for (Map element in slotSet.medicationSlots) {
      for (MedicationTime key in element.keys) {
        if (key.consumptionTime % (60 * 24) < todaysMinutes) {
          if (!element[key].wasTakenToday(key)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}

class PillTrackerModule extends BasicModule {
  var firstCamera;
  static const String pillTrackerId = "pill_tracker";
  var cameras;
  var currentView = PillTrackerView.home;
  UpdateVoidFunction update;
  MedicationManager medManager = MedicationManager();
  static const planFolderName = "Medikationsplaene";
  FileSysDirectory planFolder;

  PillTrackerModule() {
    name = "Pillentracker";
    icon = "pill";
    moduleInfo = "Der Pillentracker unterstützt dich bei der Organisation deiner Medikation, damit du deine Medizin rechtzeitig und vollständig nimmst. Im Medikamentenschrank hast du den Überblick über deine Vorräte und siehst frühzeitig, welche Medikamente du wieder aufstocken musst.";
    id = PillTrackerModule.pillTrackerId;
    availableCameras().then((test) {
      cameras = test;
      firstCamera = cameras.first;
    });
    medManager.load();
    FileSysDirectory rootDir = EncryptedFS().getRoot();
    rootDir.addDir(FileSysDirectory(DateTime.now(), planFolderName, rootDir));
    planFolder = rootDir.getChildDirWithName(planFolderName);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  @override
  bottomNavBarTap(index, BuildContext bc) {
    switch (index) {
      case 0:
        currentView = PillTrackerView.home;
        break;

      case 1:
        showModuleInfo(bc);
        break;

      case 2:
        PDFGenerator.generatePDFReportFromList(medManager.makeReport)
            .then((pdfdata) {
          String filename = "MRP_" +
              name.replaceAll(" ", "_") +
              "_" +
              DateFormat().addPattern("dd_MM_yy").format(DateTime.now()) +
              ".pdf";
          _localPath.then((path) async {
            String fullname = "$path/${filename}";
            await writeToFile(pdfdata, "$path/${filename}");
            Share.shareFiles(
              [fullname],
              text: 'Hello, check your share files!',
            );
          });
        });
        break;
    }
    if (update != null) {
      update();
    }
  }

  Widget getBottomNavBar(context, {TabController tabCtrl, VoidCallback goHome}) {
    return Theme(
        data: Theme.of(context).copyWith(
      // sets the background color of the `BottomNavigationBar`
      /*canvasColor: Colors.green,*/
      // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        highlightColor: Theme.of(context).accentColor,
        textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(caption: new TextStyle(color: Theme.of(context).primaryColorDark))), // sets the inactive color of the `BottomNavigationBar`
    child: BottomNavigationBar(
      onTap: (index) {if(index==0) {
       goHome();
      }
        this.bottomNavBarTap(index, context);},
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: this.getModuleIcon(color: null),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'Info',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.share),
          label: 'Report',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_vert),
          label: 'Mehr',
        )
      ],
        selectedItemColor: Theme.of(context).primaryColorDark,
        selectedIconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).primaryColorDark)
    ));
  }

  @override
  Widget buildModule(BuildContext context, UpdateVoidFunction callbackVoid) {
    return PillTrackerWidget(this, currentView, medManager);
/*
      MonkScaffold(
        title: name,
        body: PillTrackerWidget(this,currentView),
        bottomNavigationBar: getBottomNavBar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: getFABAction(context, callbackVoid),
          tooltip: 'Increment',
          backgroundColor: Theme.of(context).buttonColor,
          child: Icon(Icons.add),
        ));*/
  }

  @override
  Function getFABAction(BuildContext context, UpdateVoidFunction callbackVoid) {
    update = callbackVoid;
    return () {
      showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.only(top: 12),
              height: 100,
              color: Colors.white,
              child: Row(children: [
                Expanded(
                    child: Container(
                        child: Column(children: [
                  IconButton(
                      iconSize: 36,
                      icon: Icon(Icons.upload_rounded),
                      onPressed: () async {
                        Navigator.pop(context);

                        FilePickerResult result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          File file = File(result.files.single.path);
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, __, ___) =>
                                      SaveFileScreen.forFile(file,
                                          fixedFolder: planFolder),
                                  transitionDuration: Duration(seconds: 0)));
                        } else {
                          // User canceled the picker
                        }
                      }),
                  Text("Hochladen")
                ]))),
                Expanded(
                    child: Column(children: [
                  Container(
                      child: IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, __, ___) =>
                                  TakePictureScreen(
                                      first: true, fixedFolder: planFolder),
                              transitionDuration: Duration(seconds: 0)));
                    },
                  )),
                  Text("Scannen")
                ])),
                Expanded(
                    child: Column(children: [
                  Container(
                      child: IconButton(
                          iconSize: 36,
                          icon: Icon(MdiIcons.pill),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MedScreen()))
                                .then((med) {
                              if (med != null) {
                                medManager.medicationLib.add(med);
                                AccessLayer().setModuleData(
                                    PillTrackerModule.pillTrackerId,
                                    "last_entry",
                                    DateTime.now().toIso8601String());
                                medManager.saveMedicationLib();
                              }
                              update();
                            });
                          })),
                  Text("Hinzufügen")
                ])),
              ]),
            );
          });
    };

    return () {};
  }

  @override
  ModuleType getModuleType() {
    ModuleType.DartClass;
  }

  bool hasFABAction() {
    return true;
  }

  @override
  handleNotification(BasicElementNotification ben, BuildContext con) {}

  @override
  getDashWidget(BuildContext context) {
    List<int> crits = medManager.getSlotStates();
    var next = medManager.getNextConsumption();
    bool forgot = medManager.getForgotten();
    return Container(padding: EdgeInsets.only(top: 0, bottom: 5),

        child: Column(children: [
        Padding(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          createDaytimeColumn(context, 'Morgens', crits[0]),
          createDaytimeColumn(context, 'Mittags', crits[1]),
          createDaytimeColumn(context, 'Abends', crits[2]),
          createDaytimeColumn(context, 'Nachts', crits[3]),
        ],
      ),padding: EdgeInsets.only(bottom: 10)),
      next!=null ? Padding(
          padding: EdgeInsets.only(top: 0, bottom: 10),
          child: Text('Nächste Einnahme: ' +
              (next != null ? convertDateTimeToRelativeFuture(next) : ""))) : Container(),
      forgot
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top:0,bottom: 10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.warning, color: Colors.red),
                Text(' Medikation überfällig!',
                    style: TextStyle(color: Colors.red))
              ]))
          : Container(),
    ]));
  }

  getFAB(BuildContext context) {}

  createDaytimeColumn(BuildContext context, String label, int level) {
    Color col;
    switch (level) {
      case 0:
        col = Colors.grey;
        break;
      case 1:
        col = Colors.green;
        break;
      case 2:
        col = Colors.orange;
        break;
      case 3:
        col = Colors.red;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5), child: Text(label)),
        Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: SizedBox(
              width: 40,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: col),
              ),
            ))
      ],
    );
  }
}
