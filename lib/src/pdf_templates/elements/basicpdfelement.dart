

/*Table.fromTextArray(context: context, data: <List<String>>[
<String>['Msg ID', 'DateTime', 'Type', 'Body'],
...msgList.map(
(msg) => [msg.counter, msg.dateTimeStamp, msg.type, msg.body])
]*/

import 'package:pdf/widgets.dart' as pw;

abstract class BasicPDFElement {
  List<pw.Widget> parseScript(String input, pw.Context context, String moduleIdentifier);
  String key;
  String moduleIdentifier;


  static String getInnerString(String input, String tokenA, String tokenB) {
    if (input.contains(tokenA) && input.contains(tokenB)) {
      return input.substring(input.indexOf(tokenA) + 1, input.indexOf(tokenB));
    } else {
      return "";
    }
  }

  static Map getOptions(String input) {
    String inner = getInnerString(input, "[", "]");

    return getOptionsInner(inner);
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
