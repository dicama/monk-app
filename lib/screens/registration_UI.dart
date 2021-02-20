import 'package:monk/models/step_model.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:monk/src/appstore/appstore.dart';
import 'package:monk/src/dashboard/dashboard.dart';
import 'package:monk/main.dart';
import 'package:monk/src/dto/settings.dart';
import 'package:monk/src/service/accesslayer.dart';


final usernameController = TextEditingController();
final userageController = TextEditingController();
TextEditingController nameController = TextEditingController();
int progressIndicatorState = 1;
bool _checkedDataSecurity = false;
bool _isScrollable = false;
bool onboardingDone = false;
String username = "";
String age = "";
String gender = "";
String dateOfDiagnose = "";
String diagnose = 'Keine Angabe';
int tag = 1;

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<StepModel> list = StepModel.list;
  var _controller = PageController();
  var initialPage = 0;

  @override
  Widget build(BuildContext context) {
    Settings settings = AccessLayer().getSettings();
    settings.onboardingDone = onboardingDone;
    AccessLayer().setSettings(settings);
    _controller.addListener(() {
      setState(() {
        initialPage = _controller.page.round();
      });
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          _appBar(),
          _body(_controller),
          _indicator(),
        ],
      ),
    );
  }

  _appBar() {
    return Container(
      margin: EdgeInsets.only(top: 25),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (initialPage > 0)
            GestureDetector(
              onTap: () {
                if (initialPage > 0)
                  _controller.animateToPage(initialPage - 1,
                      duration: Duration(microseconds: 500),
                      curve: Curves.easeIn);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Icon(Icons.arrow_back_ios),
              ),
            ),
          if (initialPage > 0 && initialPage < list.length - 1)
            FlatButton(
              onPressed: () {
                if (initialPage > 1 && initialPage < list.length - 1) {
                  _controller.animateToPage(initialPage + 1,
                      duration: Duration(microseconds: 500),
                      curve: Curves.easeInOut);
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Dashboard()));
                }
              },
              child: Text(
                "ÜBERSPRINGEN",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _body(PageController controller) {
    return Expanded(
      child: PageView.builder(
        controller: controller,
        physics: _isScrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              SizedBox(height: 5.0),
              _displayHeader(list[index].header),
              if (index == 0)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: CheckboxListTile(
                    title: Text(
                        "ich bin damit einverstanden, dass meine Daten für die oben genannten Zwecke gespeichert und genutzt werden"),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _checkedDataSecurity,
                    activeColor: MyApp.getThemeData().buttonColor,
                    checkColor: Colors.black,
                    onChanged: (bool value) {
                      setState(() {
                        _checkedDataSecurity = value;
                      });
                    },
                  ),
                ),
              //ToDo Autofill
              //username
              if (index == 2)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: usernameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLength: 30,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Dein Name kann nicht leer sein';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      setState(() {
                        username = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Wie darf Monk dich nennen?',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ),
              //age
              if (index == 3)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: TextFormField(
                    controller: userageController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Dein Alter sollte nicht leer sein.';
                      }
                      return null;
                    },
                    //save age as String
                    onChanged: (String value) {
                      //toDo check Workaround with users
                      if(value.length==2){
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                      setState(() {
                        age = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Alter in Jahre',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ),
              //gender
              if (index == 4)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Wrap(
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
                ),
              //diagnose
              if (index == 5)
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownButtonFormField(
                      value: diagnose,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      elevation: 15,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
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
                    )),
              //date of diagnose
              if (index == 6)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: DateTimePicker(
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2050),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
                    ),
                    onChanged: (val) => dateOfDiagnose = val,
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => dateOfDiagnose = val,
                  ),
                ),
              if (index == 7)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: MyApp.getThemeData().buttonColor,
                            shadowColor:
                                MyApp.getThemeData().secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))),
                        child: Text('DASHBOARD DIREKT ERSTELLEN',
                            style: MyApp.getThemeData().textTheme.button),
                        onPressed: () {
                          onboardingDone = true;
                          saveData();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Dashboard()));
                        },
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        "ODER",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shadowColor:
                                MyApp.getThemeData().secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))),
                        child: Text('MODULE AUSWÄHLEN',
                            style: MyApp.getThemeData().textTheme.button),
                        onPressed: () {
                          onboardingDone = true;
                          saveData();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AppStore()));
                        },
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 15.0),
              Container(
                margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                alignment: Alignment.center,
                child: _displayDescription(list[index].description),
              ),
            ],
          );
        },
      ),
    );
  }

  _indicator() {
    return Container(
      width: 90,
      height: 90,
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(MyApp.getThemeData().buttonColor),
                value: (initialPage) / (list.length - 1),
              ),
            ),
          ),
          if (progressIndicatorState == 1)
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (_checkedDataSecurity == true) {
                    if (initialPage < list.length - 1) {
                      usernameController.text = username;
                      userageController.text = age;
                      //toDo Discuss Scrollable Physics with UI/UX Team (iOS Users) - Performance tests
                      //setState(() {
                        //_isScrollable = !_isScrollable;
                      //});
                      _controller.animateToPage(initialPage + 1,
                          duration: Duration(microseconds: 500),
                          curve: Curves.easeIn);
                    } else {
                      onboardingDone = true;
                      saveData();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Dashboard()));
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text(
                                  'Deine Daten haben bei MONK höchste Priorität',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              content: Text(
                                  'Bitte akzeptiere zum Fortfahren unsere Datenschutzbedingungen'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Verstanden'),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                  },
                                ),
                              ],
                            ));
                  }
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: MyApp.getThemeData().buttonColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                  child: Icon(
                    Icons.done,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (initialPage < list.length)
                    _controller.animateToPage(initialPage + 1,
                        duration: Duration(microseconds: 500),
                        curve: Curves.easeIn);
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                  child: Icon(
                    Icons.done,
                    color: Colors.black,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  _displayHeader(String text) {
    return Text(
      text,
      style: MyApp.getThemeData().textTheme.headline4,
      textAlign: TextAlign.center,
    );
  }

  _displayDescription(String text) {
    return Text(
      text,
      style: MyApp.getThemeData().textTheme.caption,
      textAlign: TextAlign.center,
    );
  }

  void saveData() {
    AccessLayer().setData("GENERAL", "0&Datenschutz", _checkedDataSecurity);
    AccessLayer().setData("GENERAL", "0&Name", username);
    AccessLayer().setData("GENERAL", "0&Alter", age);
    AccessLayer().setData("GENERAL", "0&Geschlecht", gender);
    AccessLayer().setData("GENERAL", "0&DatumDerDiagnose", dateOfDiagnose);
    AccessLayer().setData("GENERAL", "0&Diagnose", diagnose);

    Settings settings = AccessLayer().getSettings();
    settings.onboardingDone = onboardingDone;
    AccessLayer().setSettings(settings);
    // AccessLayer().setData("GENERAL", "0&OnboardingState", onboardingDone);
  }

  //toDo:
  bool validateStep() {}
}
