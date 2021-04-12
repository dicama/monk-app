import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import 'package:monk/src/appstore/appstore.dart';
import 'package:monk/src/dashboard/dashboard.dart';
import 'package:monk/src/models/DrawerModel.dart';
import 'package:monk/src/modules/modulewidget.dart';
import 'package:monk/src/notifications/notificationcenter.dart';
import 'package:monk/src/service/moduleloader.dart';
import 'package:monk/src/service/notificationmanager.dart';
import 'package:monk/src/screens/settingView.dart';
import 'package:monk/src/screens/privacy.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class MonkScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showDashboard;
  final Widget floatingActionButton;
  final Widget bottomNavigationBar;
  final TabBar tabBar;
  final Color backgroundColor;

  MonkScaffold(
      {this.title,
      this.showDashboard = false,
      this.body,
      this.floatingActionButton,
      this.bottomNavigationBar,
      this.tabBar,
      this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar:
          buildAppBar(context, title, dashboard: showDashboard, tabBar: tabBar),
      body: body,
      drawer: MonkDrawer(),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  static Widget buildAppBar(BuildContext context, String title,
      {bool dashboard = false, TabBar tabBar}) {
    return AppBar(
        bottom: tabBar,
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              new Builder(builder: (context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }),
              /*getDashIcon(dashboard, context),*/

              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Text(
                        title,
                        overflow: TextOverflow.fade,
                      ))),
            ]),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.security,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Provider.of<DrawerModel>(context, listen: false).selectedItem = "privacy";
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, __, ___) => Privacy(),
                      transitionDuration: Duration(seconds: 0)));
            },
          ),
          IconButton(
            icon: Badge(
              badgeColor: MyApp.getThemeData().accentColor,
              showBadge: NotificationManager().unreads,
              badgeContent: Text(NotificationManager().unreadNumber.toString(),
                  style: TextStyle(fontSize: 12)),
              child: Icon(
                Icons.notifications_none_outlined,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, __, ___) => NotificationCenter(),
                      transitionDuration: Duration(seconds: 0)));
// do something
            },
          ),
          IconButton(
            icon: Icon(
              Icons.apps,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Provider.of<DrawerModel>(context, listen: false).selectedItem =
                  "dashboard";
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, __, ___) => Dashboard(),
                      transitionDuration: Duration(seconds: 0)));
            },
          ),
        ]);
  }
}

class MonkDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var drawerModel = Provider.of<DrawerModel>(context);
    String selectedTile = drawerModel.selectedItem;

    var themeData = Theme.of(context);
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListTileTheme(
        textColor: themeData.primaryColorDark,
        iconColor: themeData.primaryColorDark,
        selectedColor: themeData.primaryColorDark,
        selectedTileColor: themeData.selectedRowColor,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15, top: 40),
              child: Image(
                  image: AssetImage('assets/icons/monkicon_with_text.png'),
                  height: 100,
                  alignment: Alignment.centerLeft),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10),
              child: Text("MEINE ONKOLOGIE",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
            ),
            Divider(
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(Icons.apps),
              title: Text(
                'Dashboard',
              ),
              selected: selectedTile == 'dashboard',
              onTap: () {
                Provider.of<DrawerModel>(context, listen: false).selectedItem =
                    "dashboard";

                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, __, ___) => Dashboard(),
                        transitionDuration: Duration(seconds: 0)));
              },
            ),
            ListTile(
              leading: Icon(Icons.local_grocery_store_sharp),
              title: Text(
                'Store'
              ),
              selected: selectedTile == 'store',
              onTap: () {
                Provider.of<DrawerModel>(context, listen: false).selectedItem = "store";
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, __, ___) => AppStore(),
                        transitionDuration: Duration(seconds: 0)));
              },
            ),
            Divider(
              color: Colors.grey,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10),
              child: Text("MEINE MODULE",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
            ),
            getMenuWidgets(context, selectedTile),
            Divider(
              color: Colors.grey,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10),
              child: Text("ÜBER MONK",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
            ),
            Divider(
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Einstellungen'),
              selected: selectedTile == 'settings',
              onTap: () {
                Provider.of<DrawerModel>(context, listen: false).selectedItem =
                    "settings";
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, __, ___) => SettingView(),
                        transitionDuration: Duration(seconds: 0)));
              }),
              ListTile(
                leading: Icon(Icons.security),
                title: Text('Datenschutz'),
                selected: selectedTile == 'privacy',
                onTap: () {
                  Provider.of<DrawerModel>(context, listen: false).selectedItem = "privacy";
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, __, ___) => Privacy(),
                          transitionDuration: Duration(seconds: 0)));
                },
            ),
          ],
        ),
      ),
    );
  }

  Column getMenuWidgets(BuildContext context, selectedTile) {
    List<Widget> list = new List<Widget>();
    ModuleLoader().modules.forEach((element) {
      list.add(ListTile(
        leading: element.getModuleIcon(color: Theme.of(context).primaryColorDark),
        title: Text(element.name),
        selected: selectedTile == element.name,
        onTap: () {
          Provider.of<DrawerModel>(context, listen: false).selectedItem =
              element.name;
          Provider.of<DrawerModel>(context, listen: false).selectedModule =
              element.name;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ModuleWidget(element)),
          );
        },
      ));
    });

    return Column(children: list);
  }
}
