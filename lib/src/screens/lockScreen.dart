import 'package:flutter/material.dart';
import 'package:local_auth_device_credentials/auth_strings.dart';
import 'package:local_auth_device_credentials/local_auth.dart';
import 'package:monk/main.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool isAuth = false;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return isAuth
        ? MyApp()
        : Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Padding(
                      padding: EdgeInsets.all(40),
                      child: Image(
                          image:
                              AssetImage('assets/icons/monkicon_with_text.png'),
                          height: 100,
                          alignment: Alignment.centerLeft)),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: themeData.primaryColorDark, width: 2.5)),
                    child: InkWell(
                        onTap: () {
                          _checkBiometric();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.fingerprint,
                              color: themeData.primaryColorDark,
                            ),
                            Text(
                              "Einloggen",
                              style:
                                  TextStyle(color: themeData.primaryColorDark),
                            )
                          ],
                        )),
                  )
                ])),
          );
  }

  void _checkBiometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      print("error biome trics $e");
    }

    print("biometric is available: $canCheckBiometrics");

    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      print("error enumerate biometrics $e");
    }

    if (availableBiometrics.isNotEmpty) {
      availableBiometrics.forEach((ab) {
        print("\ttech: $ab");
      });
    } else {
      print("no biometrics are available");
    }

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
          localizedReason:
              'Berühre den Fingerabdrucksensor um dich einzuloggen',
          useErrorDialogs: true,
          stickyAuth: false,
          androidAuthStrings:
              AndroidAuthMessages(signInTitle: "Bei Monk einloggen"));
    } catch (e) {
      print("error using biometric auth: $e");
    }
    setState(() {
      isAuth = authenticated ? true : false;
    });
  }
}
