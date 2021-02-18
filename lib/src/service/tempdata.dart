
class TempData {
  static final TempData _instance = TempData._internal();

  factory TempData() => _instance;

  var data = new Map();

  TempData._internal() {
    // init things inside this
  }

}
