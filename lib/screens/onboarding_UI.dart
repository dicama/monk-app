import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monk/screens/registration_UI.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monk/utilities/styles.dart';
import 'package:monk/main.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? MyApp.getThemeData().accentColor : MyApp.getThemeData().primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding_1.png',
                                ),
                                height: 350.0,
                                width: 350.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Deine Krebserkrankung\nsicher verwalten',
                              style: MyApp.getThemeData().textTheme.headline6,
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Wir ermöglichen die höchste Form des Datenschutzes. Du und nur Du bist Besitzer deiner Daten!',
                              style: MyApp.getThemeData().textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding_2.png',
                                ),
                                height: 340.0,
                                width: 340.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Dein Leben mit Krebs\nindividuell organisieren.',
                              style: MyApp.getThemeData().textTheme.headline6,
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Du wählst die Funktionien aus, die du in deinem Alltag benötigst und erstellst damit deinen persönlichen Begleiter.',
                              style: MyApp.getThemeData().textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding_3.png',
                                ),
                                height: 350.0,
                                width: 350.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Deine Ideen umsetzen',
                              style: MyApp.getThemeData().textTheme.headline6,
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Wir sind open-source, patientenzentriert und wollen eure Ideen umsetzen.',
                              style: MyApp.getThemeData().textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  verticalDirection: VerticalDirection.down,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(),
                      ),
                      _currentPage != _numPages - 1
                          ?
                        Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: MyApp.getThemeData().buttonColor, shadowColor: MyApp.getThemeData().secondaryHeaderColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                            child: Text('WEITER', style: MyApp.getThemeData().textTheme.button),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },

                      )
                      ):

                          Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: MyApp.getThemeData().buttonColor, shadowColor: MyApp.getThemeData().secondaryHeaderColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                              child: Text('LOS GEHT`S', style: MyApp.getThemeData().textTheme.button),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()),);
                              },
                            ),

                )]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
