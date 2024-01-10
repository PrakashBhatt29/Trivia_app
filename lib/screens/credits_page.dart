// Author: Daniel McErlean
// Title: Credits Page
// About: Contains documentation information, including sources and references

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadFlutterAsset('assets/documentation.html');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(context),

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Documentation",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 10,
            ),
          ),
          centerTitle: true,
          toolbarHeight: MediaQuery.of(context).size.width < 920 ? MediaQuery.of(context).size.width / 8 : kToolbarHeight,
        ),
        body: WebViewWidget(controller: controller),
      ),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return Future.value(false);
    }
    else {
      return Future.value(true);
    }
  }
}
