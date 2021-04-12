import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:monk/icons/monkiconlib.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/customwidgets/fileexplorerspecial.dart';
import 'package:monk/src/modules/lib/pilltracker/models.dart';
import 'package:monk/src/modules/lib/pilltracker/pilltracker.dart';
import 'package:monk/src/service/encryptedfs.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

import 'medscreen.dart';

// TODO: Implement Start and Endtime for PillSchedule

enum PillTrackerView { home, favorites }

class _PillTrackerWidgetState extends State<PillTrackerWidget> with TickerProviderStateMixin {
  var groupVal = -1;
  var func;
  bool isCompactRecent = false;
  bool isCompactAll = false;
  bool isFavoritesCompact = false;
  FileSysDirectory mainDirectory;
  PillTrackerView currentView = PillTrackerView.home;
  FileSysFile toOpenOnUpdate;
  ScrollController _scrollController = ScrollController();
  List<String> tabTitles = ["Mein Tag", "Med Schrank", "Pläne"];
  TabController _tabController;
  static final List<SvgPicture> consumtionTimeSlotIcons = [
    MonkIconLib.daytimeMorning,
    MonkIconLib.daytimeNoon,
    MonkIconLib.daytimeEvening,
    MonkIconLib.daytimeNight,
    MonkIconLib.medicationOnDemand
  ];
  static final List<String> consumtionTitle = [
    "Morgens",
    "Mittags",
    "Abends",
    "Nachts",
    "Bedarfsmedikamente"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this,length: tabTitles.length);
    // Get a specific camera from the list of available cameras.
  }

  alertDialog(BuildContext context, String alertText, String title) {
    // This is the ok button

    // show the alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(alertText),
          actions: [
            FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
          elevation: 5,
        );
      },
    );
  }

  Future<MedicationConsumption> takeDialog(BuildContext context, String units, DateTime shouldTime,
      double amount, {bool edit = true}) async {
    // This is the ok button

    // show the alert dialog
    DateTime date = DateTime.now();
    double consumptionAmount = amount;
    TextEditingController consumptionAmountCtrl =
        TextEditingController(text: consumptionAmount.toString());
    MedicationConsumption retVal = await showDialog(
      context: context,
      builder: (BuildContext context2) {
        return StatefulBuilder(builder: (context, setState) {
          return Theme(
              data: Theme.of(context2),
              child: Dialog(
                child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        Expanded(
                            child: Text("Einnehmen",
                                style: Theme.of(context).textTheme.headline6))
                      ]),
                      SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: Text("Einnahmemenge",
                                style: Theme.of(context).textTheme.button)),
                        Container(
                            width: 70,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+[\.\,]?\d{0,2}')),
                                ],
                                enabled: edit,
                                controller: consumptionAmountCtrl,
                                onChanged: (val) {
                                  double parsedVal = double.parse(val);
                                  consumptionAmount = parsedVal;
                                  setState(() {});
                                },
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(8),
                                  isDense: true,
                                  hintText: 'Wert',
                                  border: new OutlineInputBorder(borderSide: BorderSide(width: 2.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0),
                                    ),
                                  ),
                                ))),
                        Text(units.toUpperCase())
                      ]),
                      Row(children: [
                        Expanded(
                            child: Text("Einnahmezeit",
                                style: Theme.of(context).textTheme.button)),
                        GestureDetector(
                            onTap: () async {
                              TimeOfDay picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: date.hour, minute: date.minute),
                                builder: (BuildContext context, Widget child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: true),
                                    child: child,
                                  );
                                },
                              );
                              if (picked != null) {

                                date = new DateTime(date.year, date.month,
                                    date.day, picked.hour, picked.minute);
                                setState(() {});
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                DateFormat("HH:mm").format(date),
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center,
                              ),
                            ))
                      ]),
                      Row(children: [
                        Expanded(
                            child: FlatButton(
                                child: Text("ABBRECHEN"),
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                })),
                        Expanded(
                            child: FlatButton(
                                child: Text("EINNEHMEN"),
                                onPressed: () {
                                  Navigator.of(context).pop(MedicationConsumption(consumptionAmount, shouldTime, date));
                                }))
                      ])
                    ])),
                elevation: 5,
              ));
        });
      },
    );

    return retVal;
  }

  @override
  void didUpdateWidget(covariant PillTrackerWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    currentView = widget.initialView;
  }

  List<Widget> _buildExpandableContentMyDay(
      Map<MedicationTime, Medication> times, BuildContext bc) {
    List<Widget> children = [];
    List<MedicationTime> sortedTimes = times.keys.toList();
    sortedTimes.sort((a, b) {
      return a.consumptionTime - b.consumptionTime;
    });

    for (MedicationTime medTime in sortedTimes) {
      MedicationConsumption taken = times[medTime].getFittingConsumptionToday(medTime);
      /*bool isAvailable = times[medTime].isCurrentlyFittingConsumptionTime();*/
      children.add(Container(
          width: 170,
          height: 190,
          child: Column(
              children: ([
            Container(
                width: 68,
                height: 68,
                child: Stack(children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: GestureDetector(
                      child:MonkIconLib.medicationPills,
                      onLongPress: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedScreen(
                                      editMed: times[medTime],
                                      medicationLib:
                                          widget.medMan.medicationLib,
                                    ))).then((noparam) {
                          setState(() {});
                          widget.medMan.saveMedicationLib();
                        });
                      },
                    ),
                  ),
                  times[medTime].notes != ""
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            child: Icon(Icons.info, color: Colors.grey),
                            onTap: () {
                              alertDialog(
                                  context, times[medTime].notes, "Hinweise");
                            },
                          ))
                      : Container()
                ])),
            Container(
                padding: EdgeInsets.only(top: 8),
                child: Text(times[medTime].name,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
            Container(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                    "${medTime.amount}\u{2009}${MedicationUnitsShortStringsDE[medTime.units.index]} @${medTime.toHours()}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
            taken == null
                ? FlatButton(
                    color:
                        taken == null ? Theme.of(bc).accentColor : Colors.grey,
                    onPressed: taken == null
                        ? () async {
                      MedicationConsumption mc = await takeDialog(
                          context,
                          MedicationUnitsStringsDE[medTime.units.index],
                          medTime.getMedicationTimeToday(), medTime.amount, edit: false);

                        if(mc != null) {
                          times[medTime].availableUnits =
                              times[medTime].availableUnits - mc.amount;
                          times[medTime].consumptionHistory.add(
                              mc);
                          times[medTime].consumptionHistory.sort((a, b) {
                            return a.consumptionTime
                                .difference(b.consumptionTime)
                                .inMilliseconds;
                          });
                          widget.medMan.saveMedicationLib();
                          setState(() {});
                        }
                          }
                        : () {},

                    child: Text("Einnehmen".toUpperCase(),
                        style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Theme.of(bc).accentColor)))
                : Chip(
                    label: Text("${taken.amount}\u{2009}${MedicationUnitsShortStringsDE[times[medTime].unitsOfUnits.index]} @${DateFormat.Hm().format(taken.consumptionTimeActually)}"),
                    onDeleted: () {
                      var cons =
                          times[medTime].getFittingConsumptionToday(medTime);
                      times[medTime].availableUnits += cons.amount;
                      times[medTime].consumptionHistory.remove(cons);
                      widget.medMan.saveMedicationLib();
                      setState(() {});
                    },
                  ),
          ]))));
    }

    return children;
  }

  List<Widget> _buildAsNeededMyDay(List<Medication> meds, BuildContext bc) {
    List<Widget> children = [];
    List<Medication> sortedMeds = meds.toList();
    sortedMeds.sort((a, b) {
      return a.name.compareTo(b.name);
    });

    for (Medication med in sortedMeds) {
      var medTimes = med.getAsNeededConsumptionToday();
      children.add(Container(
          width: 170,
          child: Column(children: [
            Container(
                width: 68,
                height: 68,
                child: Stack(children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: GestureDetector(
                      child: MonkIconLib.medicationPills,
                      onLongPress: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedScreen(
                                      editMed: med,
                                      medicationLib:
                                          widget.medMan.medicationLib,
                                    ))).then((noparam) {
                          setState(() {});
                          widget.medMan.saveMedicationLib();
                        });
                      },
                    ),
                  ),
                  med.notes != ""
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            child: Icon(Icons.info, color: Colors.grey),
                            onTap: () {
                              alertDialog(context, med.notes, "Hinweise");
                            },
                          ))
                      : Container()
                ])),
            Container(
                padding: EdgeInsets.only(top: 8),
                child: Text(med.name,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
            ListView.builder(
              itemCount: medTimes.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Chip(
                    label: Text("${medTimes[index].amount}\u{2009}${MedicationUnitsShortStringsDE[med.unitsOfUnits.index]} @${DateFormat.Hm().format(medTimes[index].consumptionTimeActually)}"),
                  onDeleted: () {
                    med.consumptionHistory.remove(medTimes[index]);
                    setState(() {});
                    widget.medMan.saveMedicationLib();
                  },
                );
              },
            ),
            FlatButton(
                color: Theme.of(bc).accentColor,
                onPressed: () async {
                  MedicationConsumption mc = await takeDialog(context,
                      MedicationUnitsStringsDE[med.unitsOfUnits.index],
                      DateTime.now(), 1);

                  if(mc != null) {
                    mc.isAsNeeded = true;
                    med.availableUnits =
                        med.availableUnits - mc.amount;
                    med.consumptionHistory.add(
                        mc);
                    med.consumptionHistory.sort((a, b) {
                      return a.consumptionTime
                          .difference(b.consumptionTime)
                          .inMilliseconds;
                    });
                    widget.medMan.saveMedicationLib();
                    setState(() {});
                  }
                },
                child: Text("Einnehmen".toUpperCase()),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Theme.of(bc).accentColor))),
          ])));
    }

    return children;
  }

  List<Widget> _buildExpandableContentMedChest(
      List<Medication> meds, BuildContext bc) {
    List<Widget> children = [];
    for (Medication med in meds) {
      children.add(Column(children: [
        ListTile(
            leading: Container(
              child: MonkIconLib.medicationPills,
              width: 47,
              height: 47,
            ),
            title: Text(med.name,
                style: Theme.of(bc)
                    .textTheme
                    .subtitle1
                    .merge(TextStyle(fontWeight: FontWeight.w700))),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MedScreen(
                              editMed: med,
                              medicationLib: widget.medMan.medicationLib,
                            ))).then((noparam) {
                  setState(() {});
                  widget.medMan.saveMedicationLib();
                });
              },
            ),
            subtitle: Column(
              children: [
                Row(children: [
                  Icon(Icons.access_time, size: 14),
                  Text(" " + med.getAllHoursAsString())
                ]),
                Row(children: [
                  Icon(Icons.medical_services, size: 14),
                  Text(" " + med.category)
                ])
              ],
            )),
        Container(
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
                "${med.availableUnits.round()} / ${med.initalUnits.round()}")),
        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
          height: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: med.availableUnits / med.initalUnits,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  getAvailabilityColor(med.availableUnits / med.initalUnits)),
              backgroundColor: Colors.grey,
            ),
          ),
        )
      ]));
    }

    return children;
  }

  static Color getAvailabilityColor(double ratio) {
    if (ratio > 0.5) {
      return Colors.green;
    } else if (ratio > 0.1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget tabMyDay(BuildContext bc, num) {
    widget.medMan.buildSlots();

    return Container(
      child: SingleChildScrollView(
          child: Column(children: [
        Container(
            padding: EdgeInsets.all(8),
            child: Text(
                DateFormat("EEEE, d.M.y", Localizations.localeOf(bc).toString())
                    .format(DateTime.now()),
                style: Theme.of(bc).textTheme.headline6)),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, i) {
              return new ExpansionTile(
                  initiallyExpanded: false,
                  leading: consumtionTimeSlotIcons[i],
                  title: new Text(consumtionTitle[i].toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle2),
                  subtitle: Text(
                      i < 4
                          ? "${widget.medMan.slotSet.medicationSlotsTaken[i]}/${widget.medMan.slotSet.medicationSlotsNumber[i]}"
                          : "nach Bedarf",
                      style: Theme.of(context).textTheme.bodyText2),
                  children: <Widget>[
                    Wrap(
                        children: i < 4
                            ? _buildExpandableContentMyDay(
                                widget.medMan.slotSet.medicationSlots[i], bc)
                            : _buildAsNeededMyDay(
                                widget.medMan.asNeededMeds, bc)),
                  ]);
            })
      ])),
    );
    ;
  }

  Widget tabMedChest(BuildContext bc, num) {
    widget.medMan.buildCategories();
    List<String> sortedCats = widget.medMan.medicationCategories.keys.toList();
    sortedCats.sort();
    Map sR = widget.medMan.getSmallestRatioPerCategory();

    return Container(
      child: SingleChildScrollView(
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sortedCats.length,
              itemBuilder: (context, i) {
                return new ExpansionTile(
                    initiallyExpanded: false,
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.circle,
                            color: getAvailabilityColor(sR[sortedCats[i]])),
                      ],
                    ),
                    title: new Text(sortedCats[i],
                        style: Theme.of(context).textTheme.subtitle2),
                    subtitle: Text(
                        "${widget.medMan.medicationCategories[sortedCats[i]].length} Medikamente",
                        style: Theme.of(context).textTheme.bodyText2),
                    children: <Widget>[
                      Wrap(
                        children: _buildExpandableContentMedChest(
                            widget.medMan.medicationCategories[sortedCats[i]],
                            bc),
                      )
                    ]);
              })),
    );
  }

  Widget tabPlans(BuildContext bc, num) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: FileExplorerSpecWidget(
              widget.module.planFolder,
              limitToInitialDir: true,
            )));
  }

  List<Widget> getTabs(BuildContext bc) {
    List<Widget> tabs = new List<Widget>();

    tabs.add(tabMyDay(bc, 0));
    tabs.add(tabMedChest(bc, 0));
    tabs.add(tabPlans(bc, 0));

    return tabs;
  }

  List<Widget> getTabTitles(BuildContext bc) {
    List<Widget> tabTit = new List<Widget>();

    tabTitles.forEach((element) {
      tabTit.add(Tab(child: Text(element.toUpperCase())));
    });

    return tabTit;
  }

  void goHome()
  {
    _tabController.animateTo(0);
    print("animateto");
    setState(() {});
  }


  int getTabsNumber() {
    return tabTitles.length;
  }

  Widget getTabBar(BuildContext bc) {
    return TabBar(tabs: getTabTitles(bc),controller: _tabController);
  }

  Widget getTabBarView(BuildContext bc, {TabController ctrl}) {
    return TabBarView(
      children: getTabs(bc), controller: ctrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.module.getFABAction(context, () {
      setState(() {});
    });
    return NotificationListener<BasicElementNotification>(
        onNotification: (notification) {
          widget.module.handleNotification(notification, context);
          return true;
        },


            child: MonkScaffold(
                title: widget.module.name,
                tabBar: getTabBar(context),
                body: getTabBarView(context, ctrl: _tabController),
                bottomNavigationBar: widget.module.getBottomNavBar(context, goHome: goHome),
                floatingActionButton: FloatingActionButton(
                    tooltip: 'Increment',
                    child: Icon(Icons.add),
                    backgroundColor: Theme.of(context).buttonColor,
                    onPressed: widget.module.getFABAction(context, () {
                      setState(() {});
                    }))

                /**/
                /*widget.module.handleNotification(
                        BasicElementNotification("FAB", "pressed",
                            BasicElementNotificationType.Action),
                        context);*/

                ));
  }
}

class PillTrackerWidget extends StatefulWidget {
  final PillTrackerView initialView;
  final PillTrackerModule module;
  final MedicationManager medMan;

  const PillTrackerWidget(this.module, this.initialView, this.medMan);

  @override
  _PillTrackerWidgetState createState() => _PillTrackerWidgetState();
}
