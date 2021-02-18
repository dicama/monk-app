import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/notificationmanager.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:monk/utilities/colors.dart';

import 'basicmodule.dart';

class UpdateNotification extends Notification {}

class _ModuleWidgetState extends State<ModuleWidget> {
  static getBottomNavBar(BuildContext context, BasicModule module) {
    return Theme(
        data: Theme.of(context).copyWith(
      // sets the background color of the `BottomNavigationBar`
        /*canvasColor: Colors.green,*/
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        primaryColor: Colors.red,
        highlightColor: Theme.of(context).accentColor,
        textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(caption: new TextStyle(color: Theme.of(context).primaryColorDark))), // sets the inactive color of the `BottomNavigationBar`
    child: BottomNavigationBar(
      onTap: (index) => module.bottomNavBarTap(index, context),
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: module.getModuleIcon(color: null),
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
        ),
      ],
    selectedItemColor: Theme.of(context).primaryColorDark,
    selectedIconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).primaryColorDark)

    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentModule is Module) {
      Module moduleCurrentModule = widget.currentModule;
      if (moduleCurrentModule.tabbed) {
        return NotificationListener<BasicElementNotification>(
            onNotification: (notification) {
              moduleCurrentModule.handleNotification(notification, context);
              return true;
            },
            child: DefaultTabController(
                length: moduleCurrentModule.getTabsNumber(),
                child: MonkScaffold(
                    title: moduleCurrentModule.name,
                    tabBar: moduleCurrentModule.getTabBar(context),
                    body: moduleCurrentModule.getTabBarView(context),
                    bottomNavigationBar:
                        getBottomNavBar(context, widget.currentModule),
                    floatingActionButton: FloatingActionButton(
                      tooltip: 'Increment',
                      child: Icon(Icons.add),
                      backgroundColor: Theme.of(context).buttonColor,
                      onPressed: () {
                        moduleCurrentModule.handleNotification(
                            BasicElementNotification("FAB", "pressed",
                                BasicElementNotificationType.Action),
                            context);
                      },
                    ))));
      } else {
        return NotificationListener<BasicElementNotification>(
            onNotification: (notification) {
              moduleCurrentModule.handleNotification(notification, context);
              return true;
            },
            child: MonkScaffold(
                title: moduleCurrentModule.name,
                body: widget.currentModule.base == "list"
                    ? ListView(
                        padding: const EdgeInsets.all(8),
                        children: moduleCurrentModule.getWidget(context))
                    : Container(
                        constraints: BoxConstraints.expand(),
                        child: Column(
                            children: moduleCurrentModule.getWidget(context))),
                bottomNavigationBar:
                    getBottomNavBar(context, widget.currentModule),
                floatingActionButton: widget.currentModule.hasFABAction()
                    ? FloatingActionButton(
                        onPressed: () {
                          moduleCurrentModule.handleNotification(
                              BasicElementNotification("FAB", "pressed",
                                  BasicElementNotificationType.Action),
                              context);
                        },
                        tooltip: 'FAB',
                        backgroundColor: Theme.of(context).buttonColor,
                        child: Icon(Icons.add),
                      )
                    : Container()));
      }
    } else {
      return NotificationListener<UpdateNotification>(
          onNotification: (not) {
            setState(() {
              print("updating");
            });
            return true;
          },
          child: widget.currentModule.buildModule(context, () {
            setState(() {});
          }));
    }
  }
}

class ModuleWidget extends StatefulWidget {
  final BasicModule currentModule;

  ModuleWidget(this.currentModule);

  @override
  _ModuleWidgetState createState() => _ModuleWidgetState();
}
