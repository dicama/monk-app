import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/modules/modulewidget.dart';
import 'package:monk/src/service/notificationmanager.dart';

import 'notificationitem.dart';

class _NotififcationCenterState extends State<NotificationCenter> {
  List<bool> expandeds = List<bool>();
  List<NotificationItem> nots;

  @override
  Widget build(BuildContext context) {
    nots = NotificationManager().getNotifications();
    if (expandeds.length != NotificationManager().unreadNumber) {
      expandeds = List.filled(NotificationManager().unreadNumber, false,
          growable: true);
    }
    List<Widget> wigs = getNCWidgets(context, nots);
    return MonkScaffold(
      title: "Benachrichtigungen",
      body: wigs.isEmpty?  Center(child: Text("Keine Benachrichtigungen")) : ListView.separated(

          /*expansionCallback: (num, expan) {
                setState(() {
                  expandeds[num] = !expan;
                  print("Expandend:" + expan.toString());
                });
              },*/
          separatorBuilder: (content, index) => Divider(color: Colors.grey),
          itemCount: wigs.length,
          itemBuilder: (content, index) => wigs[index]),
    );
  }

  List<Widget> getNCWidgets(BuildContext context, List<NotificationItem> nots) {
    List<Widget> dash = new List<Widget>();
    int count = 0;
    for (var i = 0; i < nots.length; i++) {
      if (nots[i].unread) {
        dash.add(getNCWidget(context, i, expandeds[count], count));
        count++;
      }
    }
    return dash;
  }

  Widget getNCWidget(
      BuildContext context, int num, bool expanded, int expandscount) {
    /*,showBadge: unread, position: BadgePosition.topStart(top: 0, start: 0),badgeContent: Text("!"),)*/
    return Dismissible(
        // Each Dismissible must contain a Key. Keys allow Flutter to
        // uniquely identify widgets.mhv
        key: Key(num.toString()),
        // Provide a function that tells the app
        // what to do after an item has been swiped away.
        onDismissed: (direction) {
          // Remove the item from the data source.
          final id = num;
          setState(() {
            nots[id].unread = false;
            NotificationManager().calcNumberOfUnreadNotifications();
          });

          // Show a snackbar. This snackbar could also contain "Undo" actions.
         },
        child: GestureDetector(
            onTap: () {
              setState(() {
                nots[num].unread = false;
                NotificationManager().calcNumberOfUnreadNotifications();
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ModuleWidget(nots[num].origin)),
              );
            },
            child: Container(
                padding: EdgeInsets.fromLTRB(18, 8, 8, 4),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                        child: Column(children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(2),
                              child: Icon(MdiIcons.fromString(nots[num].icon),
                                  size: 14)),
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    nots[num].origin.name.toUpperCase(),
                                    style: Theme.of(context).textTheme.overline,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                  ))),
                          Container(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                  DateFormat("dd.MM.yyyy")
                                      .format(nots[num].birth),
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline
                                      .merge(TextStyle(color: Colors.grey)))),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  expandeds[expandscount] = !expanded;
                                });
                              },
                              child: Container(
                                  padding: EdgeInsets.all(0),
                                  width: 20,
                                  height: 20,
                                  child: expanded
                                      ? Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 20,
                                        )
                                      : Icon(Icons.keyboard_arrow_down,
                                          size: 20)))
                        ],
                      ),
                      Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.all(2),
                          child: Text(nots[num].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyText2),
                        ))
                      ])
                    ])),
                  ]),
                  Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(2),
                      child: Text(nots[num].message,
                          maxLines: expanded ? 10 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption),
                    ))
                  ])
                ]))));
  }
}

class NotificationCenter extends StatefulWidget {
  NotificationCenter();

  @override
  _NotififcationCenterState createState() => _NotififcationCenterState();
}
