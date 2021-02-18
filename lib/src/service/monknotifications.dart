import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



typedef NotificationCallback(String payload);

class MonkNotifications {
  static final MonkNotifications _instance = MonkNotifications._internal();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  factory MonkNotifications() => _instance;

  initNotifications(NotificationCallback callback) async
  {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher_foreground');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: (id,titile,body,payload) {});
    final MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: callback);



  }


  MonkNotifications._internal() {
    // init things inside this
  }

  scheduleNotificationsForNextWeek () async
  {
    flutterLocalNotificationsPlugin.cancelAll();

    List<int> allVals = [];

    /*for (TherapistEdits value in FynderData().myList) {
      if(value.isUncalledState()) {
        if (value.therapist.phoneHours != null) {
          allVals.addAll(value.therapist.phoneHours);
        }
      }

    }

    var results = allVals.toSet().toList();
    var tillnow = TimeSlots.getTimeSlotsTodayTillNowBase5();
    print(tillnow);
    print(results);
    tillnow.forEach((element) {
      results.remove(element);
    });
    results.sort();
    print(results);
    List<List<int>> clusters = TimeSlots.findAdjacentSlots(results);


    var count = 0;
    await Future.forEach(clusters, (element) async {
      final List<tz.TZDateTime> range = TimeSlots.convertClusterToDateTimeBase5(element);

      final int notDuration = range[1].difference(range[0]).inMilliseconds;

      await flutterLocalNotificationsPlugin.zonedSchedule(
          count,
          'Erreichbarkeit',
          'Juhuu...es ist jemand erreichbar. Ruf gleich an!',
          range[0],
          NotificationDetails(
              android: AndroidNotificationDetails('your channel id',
                  'your channel name', 'your channel description',timeoutAfter: notDuration)),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);

       count++;
    });


    print("Updating with $count Notifications");*/



  }



}
