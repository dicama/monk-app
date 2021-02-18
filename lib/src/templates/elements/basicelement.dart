import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/service/accesslayer.dart';

enum BasicElementNotificationType { Data, Action, Select }

class BasicElementNotification extends Notification {
  final String key;
  final dynamic value;
  final BasicElementNotificationType type;

  BasicElementNotification(this.key, this.value, this.type);
}

abstract class BasicElement {
  Widget parseScript(String input, Module parent, String moduleId,
      {Map parentOptions});

  String key;

  static Future<String> getFileData(String path) async {
    return await rootBundle.loadString("assets/res/pool/" + path);
  }

  static String getInnerString(String input, String tokenA, String tokenB) {
    if (input.contains(tokenA) && input.contains(tokenB)) {
      return input.substring(input.indexOf(tokenA) + 1, input.indexOf(tokenB));
    } else {
      return "";
    }
  }

  static Map getOptions(String input, {Map parentOptions}) {
    String inner = getInnerString(input, "[", "]");

    return getOptionsInner(inner, parentOptions: parentOptions);
  }

  static dynamic getInitialValue(
      Map options, BuildContext context, dynamic defVal) {
    var initValue;

    if (options["data"].startsWith(".") &&
        options["parent"].containsKey("mode") &&
        options["parent"]["mode"] == "edit") {
      List<String> splitted = options["parent"]["data"].split(":");

      var selectedData =
          AccessLayer().getModuleCacheData(splitted[0] + "#selected");

      initValue = selectedData[options["data"].substring(1)];
    } else {
      if (options.containsKey("defaultvalue")) {
        initValue = options["defaultvalue"];
      } else {
        initValue = defVal;
      }
    }

    return initValue;
  }

  static int getInitialValueInt(
      Map options, BuildContext context, dynamic defVal) {
    var int0 = getInitialValue(options, context, defVal);
    int retVal;
    if (int0 is int) {
      retVal = int0;
    } else {
      retVal = int.parse(int0);
    }

    BasicElementNotification(
            options["data"], retVal, BasicElementNotificationType.Data)
        .dispatch(context);

    return retVal;
  }

  static List<String> getInitialValueListString(
      Map options, BuildContext context, dynamic defVal) {
    var val = getInitialValue(options, context, defVal);

    List<String> retVal;

    if (val == null) {
      return null;
    } else if (val == "emptydefault") {
      retVal = [];
    } else {
      List<dynamic> list0 = val;

      retVal = list0.cast<String>();
    }
    print(val.toString());
    BasicElementNotification(
            options["data"], retVal, BasicElementNotificationType.Data)
        .dispatch(context);

    return retVal;
  }

  static DateTime getInitialValueDate(
      Map options, BuildContext context, dynamic defVal) {
    var dt = getInitialValue(options, context, defVal);

    DateTime retVal;
    if (dt is DateTime) {
      retVal = dt;
    } else {
      retVal = DateTime.parse(dt);
    }

    BasicElementNotification(options["data"], retVal.toIso8601String(),
            BasicElementNotificationType.Data)
        .dispatch(context);

    return retVal;
  }

  static String getInitialValueString(
      Map options, BuildContext context, dynamic defVal) {
    String dt = getInitialValue(options, context, defVal).toString();

    BasicElementNotification(
            options["data"], dt, BasicElementNotificationType.Data)
        .dispatch(context);

    return dt;
  }

  static Map getOptionsInner(String inner, {Map parentOptions}) {
    Map a = Map();
    List<String> tokens = inner.split(";");
    tokens.forEach((element) {
      int splitted = element.indexOf("=");
      a[element.substring(0, splitted)] = element.substring(splitted + 1);
    });
    if (parentOptions != null) {
      a["parent"] = parentOptions;
    } else {
      a["parent"] = Map();
    }

    return a;
  }

  static Map getStyle(String input) {
    Map a = Map();
    if (input.contains("{")) {
      String inner = getInnerString(input, "{", "}");
      List<String> tokens = inner.split(";");
      tokens.forEach((element) {
        var splitted = element.split("=");
        a[splitted[0]] = splitted[1];
      });
    }
    return a;
  }
}
