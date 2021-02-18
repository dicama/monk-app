import 'package:flutter/foundation.dart';

class DrawerModel extends ChangeNotifier {

  String selectedItem = "dashboard";
  String selectedModule = "";

  setSelectedItem(String selectedItem) {
    this.selectedItem = selectedItem;
    this.selectedModule = "";
    notifyListeners();
  }

  setSelectedModule(String selectedModule) {
    this.selectedModule = selectedModule;
    notifyListeners();
  }
}
