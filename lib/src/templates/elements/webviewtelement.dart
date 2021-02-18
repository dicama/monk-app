import 'package:flutter/material.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewElement extends BasicElement {
  final String key = "WebView";

  Widget parseScript(String input, Module parent, String moduleId, {Map parentOptions}) {
    String inner = BasicElement.getInnerString(input, "[", "]");
    return Expanded(child: WebView(
          initialUrl: inner,
            javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  Function parseScriptMeta(String input, State st, Map locals)
  {
    final String inner = BasicElement.getInnerString(input, "[", "]");
    return (BuildContext context) => Container(
        height: 500,
        child: WebView(
          initialUrl: inner,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      );

  }
}
