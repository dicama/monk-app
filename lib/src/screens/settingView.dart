import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/screens/personal.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/screens/oss.dart';


class SettingView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SettingState();
  }
}

class SettingState extends State<SettingView> {
  var settings = AccessLayer().getSettings();

  @override
  Widget build(BuildContext context) {
    return MonkScaffold(
      title: "Einstellungen",
      body: ListView(padding: const EdgeInsets.all(10), children: [
        CheckboxListTile(
            value: settings.useLock,
            title: Text("App-Sperre verwenden"),
            onChanged: (newValue) {
              setState(() {
                settings.useLock = newValue;
                AccessLayer().setSettings(settings);
                AppLock.of(context).setEnabled(settings.useLock);
              });
            }),
        ListTile(
            title: Text('Persönliche Informationen'),
            onTap: () {
              Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (context, __, ___) => PersonalView(),
                  transitionDuration: Duration(seconds: 0)));
            }),
        ListTile(
            title: Text('Open Source Software'),
            onTap: () {
              Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, __, ___) => OssLicensesPage(),
                      transitionDuration: Duration(seconds: 0)));
            }),
        ListTile(
            title: Text('Daten löschen'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Appdaten löschen',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      content: Text(
                          'Achtung: Hierbei werden alle Datensätze unwideruflich gelöscht.\n\nMONK erstellt keine Backups. Gelöschte Daten können nicht wieder hergestellt werden'),
                      actions: <Widget>[
                        FlatButton(
                            child: Text('ABBRECHEN'),
                            onPressed: () {
                              var count = 0;
                              Navigator.popUntil(context,
                                      (route) {
                                    return count++ == 1;
                                  });
                            }),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).buttonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      20.0))),
                          child: Text(
                              'DATEN VOLLSTÄNDIG LÖSCHEN',
                              style:
                              Theme.of(context).textTheme.button),
                          onPressed: () {
                            var count = 0;
                            AccessLayer().deleteCompleteData();
                            setState(() {});
                            Navigator.popUntil(context,
                                    (route) {
                                  return count++ == 1;
                                });
                          },
                        ),
                      ],
                    );
                  });
            }),
      ])
    );
  }
}
