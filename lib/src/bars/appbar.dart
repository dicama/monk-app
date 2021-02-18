import 'package:flutter/material.dart';
import 'package:monk/src/dashboard/dashboard.dart';

class GeneralAppBar {
  static final Color iconColor = const Color.fromARGB(255, 66, 66, 66);

  static Widget getDashIcon(bool dashboard, BuildContext context,
      {TabBar tabBar}) {
    if (dashboard) {
      return Image(
        image: AssetImage('assets/icons/monkicon.png'),
        width: 48,
        height: 48,
      );
    } else {
      return IconButton(
          icon: Icon(Icons.dashboard, color: iconColor),
          onPressed: () {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, __, ___) => Dashboard(),
                    transitionDuration: Duration(seconds: 0)));
// do something
          });
    }
  }

}
