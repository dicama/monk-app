import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:monk/src/dashboard/dashboard.dart';
import 'package:monk/src/dto/settings.dart';
import 'package:monk/src/models/DrawerModel.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/service/cameraservice.dart';
import 'package:monk/src/service/moduleloader.dart';
import 'package:monk/src/service/monknotifications.dart';

import 'package:monk/src/templates/reassemblelistener.dart';
import 'package:monk/src/screens/lockScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:monk/screens/onboarding_UI.dart';
import 'package:monk/src/service/encryptedfs.dart';

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

void main() async {
  if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  var settings = AccessLayer().getSettings();

  runApp(AppLock(
    builder: (args) => MyApp(),
    lockScreen: MaterialApp(theme: MyApp.getThemeData(), home: LockScreen()),
    enabled: settings.useLock,
  ));
}

Future initApp() async {
  Stopwatch stopwatch = new Stopwatch()..start();
  CameraService().init();
  MonkNotifications().initNotifications((payload) {});
  await AccessLayer().init();
  await EncryptedFS().init();
  await ModuleLoader().loadModules();

  if (await Permission.storage.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Settings settings = AccessLayer().getSettings();
    if (!settings.onboardingDone) {
      return ReassembleListener(
          onReassemble: () => ModuleLoader().loadModules(force: true),
          child: MultiProvider(
              providers: [
                ListenableProvider(create: (context) => DrawerModel()),
              ],
              child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Monk',
                  theme: getThemeData(),
                  home: OnboardingScreen(),
                  localizationsDelegates: [
                    // ... app-specific localization delegate[s] here
                    // TODO: uncomment the line below after codegen
                    // TODO: Provde ide delegate to have localization info wihtout context
                    // AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    const Locale('en', 'US'), // English
                    const Locale('de', 'DE'), // Hebrew
                  ])));
    } else {
      return ReassembleListener(
          onReassemble: () => ModuleLoader().loadModules(force: true),
          child: MultiProvider(
              providers: [
                ListenableProvider(create: (context) => DrawerModel()),
              ],
              child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Monk',
                  theme: getThemeData(),
                  home: Dashboard(),
                  localizationsDelegates: [
                    // ... app-specific localization delegate[s] here
                    // TODO: uncomment the line below after codegen
                    // AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    const Locale('en', ''), // English
                    const Locale('de', ''), // Hebrew
                  ])));
    }
  }

  static ThemeData getThemeData() {
    return ThemeData(
      fontFamily: 'OpenSans',
      primaryColor: Color.fromRGBO(240, 238, 242, 1),
      primaryColorDark: Color.fromRGBO(45, 21, 83, 1),
      splashColor: Color.fromRGBO(45, 21, 83, 1),
      accentColor: Color.fromRGBO(255, 212, 42, 1),
      buttonColor: Color.fromRGBO(255, 212, 42, 1),
      secondaryHeaderColor:  Color.fromRGBO(255, 212, 42, 0.5),
      selectedRowColor: Color.fromRGBO(255, 212, 42, 1),
      textSelectionColor: Color.fromRGBO(160, 158, 162, 1),
      iconTheme: IconThemeData(color: Color.fromRGBO(45, 21, 83, 1),),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      backgroundColor: Color.fromRGBO(160, 158, 162, 1),
      canvasColor: Colors.white,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(primary: Color.fromRGBO(45, 21, 83, 1)),
      textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w300),
          headline2: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w300),
          headline3: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.normal),
          headline4: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.normal),
          headline5: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal),
          headline6: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal),
          subtitle1: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal),
          subtitle2: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600),
          bodyText1: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal),
          bodyText2: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal),
          button: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold),
          caption: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal),
          overline: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );

    /*return ThemeData(
      primaryColor: Color.fromRGBO(240, 238, 242, 1),
      primaryColorDark: Color.fromRGBO(0, 0, 0, 0),
      accentColor: Color.fromRGBO(53, 242, 155, 1),
      buttonColor: Color.fromRGBO(53, 242, 155, 1),
      secondaryHeaderColor: Color.fromRGBO(227, 253, 238, 1),
      selectedRowColor: Color.fromRGBO(53, 242, 155, 1),
      textSelectionColor: Color.fromRGBO(160, 158, 162, 1),
      iconTheme: IconThemeData(color: Color.fromARGB(255, 66, 66, 66)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      backgroundColor: Colors.red,
      canvasColor: Colors.white,
      textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 96,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w300),
          headline2: TextStyle(
              fontSize: 60,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w300),
          headline3: TextStyle(
              fontSize: 48,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          headline4: TextStyle(
              fontSize: 34,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          headline5: TextStyle(
              fontSize: 24,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          headline6: TextStyle(
              fontSize: 20,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          subtitle1: TextStyle(
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          subtitle2: TextStyle(
              fontSize: 14,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600),
          bodyText1: TextStyle(
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          bodyText2: TextStyle(
              fontSize: 14,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          button: TextStyle(
              fontSize: 14,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.bold),
          caption: TextStyle(
              fontSize: 12,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.normal),
          overline: TextStyle(
              fontSize: 10,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600)),
    );*/
  }
}
