import 'package:monk/src/modules/basicmodule.dart';

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
