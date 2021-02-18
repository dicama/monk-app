import 'package:flutter/material.dart';
import 'package:monk/src/notifications/notificationitem.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;
  bool loaded = false;
  bool unreads = false;
  int unreadNumber = 0;

  List<NotificationItem> notifications = new List<NotificationItem>();

  NotificationManager._internal();

  getNotifications()
  {
    return notifications;
  }



  add(NotificationItem ni)
  {
    notifications.add(ni);
    calcNumberOfUnreadNotifications();
  }

  void loadFromDataLayer(fileName) {
    // TODO: write loading function for notifications from data layer
  }

  void calcNumberOfUnreadNotifications() {
    int count = 0;
    notifications.forEach((element) {
      if (element.unread) {
        count++;
      }
    });
    unreadNumber = count;
    if (count > 0) {
      unreads = true;
    } else {
      unreads = false;
    }
  }

  void loadNotifications() {}
}
