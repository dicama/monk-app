

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/moduledashboardwidget.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

enum ModuleType {
   MonkScript,
   DartClass,
}

typedef UpdateVoidFunction = void Function();


abstract class BasicModule
{

  Widget buildModule(BuildContext context, UpdateVoidFunction updateCallBack);
  bottomNavBarTap(index, BuildContext bc);
  ModuleType getModuleType();
  bool hasFABAction();
  handleNotification(BasicElementNotification ben, BuildContext con);
  getDashWidget(BuildContext context);

  Widget getDashboardWidget(BuildContext context, {isCompact = false}) {
    return ModuleDashboardWidget(this, isCompact: isCompact);
  }



  Function getFABAction(BuildContext bc, UpdateVoidFunction callbackVoid) {
    return () {};
  }

  showModuleInfo(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(moduleInfo),
                ],
              ),
            ),
          );
        });
  }

  Widget getModuleIcon({ double size: 24.0,color: Colors.black }) {
    if (iconUrl == null && icon == null) {
      return Icon(Icons.error);
    } else if (iconUrl == null) {
      return Icon(MdiIcons.fromString(icon), size: size, color: color);
    } else {
      return SvgPicture.file(File(iconUrl),color: color);
    }
  }
  String id;
  String iconUrl;
  String base = "list";
  String icon ="";
  String name ="";
  String moduleInfo = "";
  List<AddressOwnerAttempt> addresses = new List();
  List<AddressAccessAttempt> readAccess = new List();
}

class AddressAccessAttempt {
  String address;
  String description;

  AddressAccessAttempt(this.address, this.description);
}

class AddressOwnerAttempt {
  String address;
  String label;
  String description;

  AddressOwnerAttempt(this.address, this.label, this.description);
}
