import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monk/src/appstore/appstore.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/models/DrawerModel.dart';
import 'package:monk/src/modules/modulewidget.dart';
import 'package:monk/src/service/moduleloader.dart';
import 'package:provider/provider.dart';

class _DashboardState extends State<Dashboard> {
  var func;
  Map<String, Widget> _dashboardModules;
  List<String> _keys;
  StreamSubscription strsub;
  bool isCompact = false;

  @override
  void initState() {
    super.initState();

    strsub = ModuleLoader().moduleChange.stream.listen((msg) {
      setState(() {});
    });
  }

  void dispose() {
    super.dispose();

    strsub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _dashboardModules = ModuleLoader().getDashboardWidgetsMap(context, isCompact: isCompact);
    _keys = ModuleLoader().moduleOrder;

    return MonkScaffold(
      /*backgroundColor: Colors.grey[300],*/
      title: "Dashboard",
      showDashboard: true,
      body: NotificationListener<UpdateNotification>(
          onNotification: (not) {
            setState(() {});
            return true;
          },
          child: Column(children: [
            Container(
                height: 35,
                padding: EdgeInsets.fromLTRB(12, 2,6, 0),
                child: Row(children: [
                  Expanded(child:Container(padding: EdgeInsets.only(top:6),
                      child: Text("MEINE MODULE",
                          style: Theme.of(context).textTheme.overline))),
                  IconButton(
                    icon: Icon(
                        isCompact ? Icons.view_agenda_outlined :  Icons.list ),
                    onPressed: () {
                      setState(() {
                        isCompact = !isCompact;
                      });
                    },
                  )
                ])),
            Expanded(
                child: ReorderableListView(
              padding: const EdgeInsets.all(0),
              onReorder: (int start, int current) {
                if (start < current) {
                  int end = current - 1;
                  String startItem = _keys[start];
                  int i = 0;
                  int local = start;
                  do {
                    _keys[local] = _keys[++local];
                    i++;
                  } while (i < end - start);
                  _keys[end] = startItem;
                }
                // dragging from bottom to top
                else if (start > current) {
                  String startItem = _keys[start];
                  for (int i = start; i > current; i--) {
                    _keys[i] = _keys[i - 1];
                  }
                  _keys[current] = startItem;
                }
                ModuleLoader().setAppOrder(_keys);
                setState(() {});
              },
              children: _keys.map((item) => _dashboardModules[item]).toList(),
            ))
          ])),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: () {
          Provider.of<DrawerModel>(context, listen: false).selectedItem = "store";
          Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, __, ___) => AppStore(),
                      transitionDuration: Duration(seconds: 0)))
              .then((noparam) {
            setState(() {});
          });
        },
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  Dashboard();

  @override
  _DashboardState createState() => _DashboardState();
}
