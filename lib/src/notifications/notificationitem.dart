import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/basicmodule.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/modules/modulewidget.dart';
import 'package:monk/src/service/notificationmanager.dart';

class NotificationItem {
  bool unread;
  DateTime death;
  DateTime birth;
  final String message;
  final String title;
  final String icon;
  final BasicModule origin;

  NotificationItem(
      this.message, this.icon, this.origin, this.death, this.title) {
    unread = true;

    birth =
        DateTime.now(); // TODO: Implement constructor with birth other than now
  }
}
