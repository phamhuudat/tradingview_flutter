
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
//import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
//import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
//import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
final InAppLocalhostServer localhostServer = InAppLocalhostServer(
    port: 8888);
// #enddocregion platform_imports
Future<void> main() async {

  //"setEnvironment('AAA','VI')";
    WidgetsFlutterBinding.ensureInitialized();
    localhostServer.start();
    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

      var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        AndroidServiceWorkerController serviceWorkerController =
        AndroidServiceWorkerController.instance();

        await serviceWorkerController
            .setServiceWorkerClient(AndroidServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            print(request);
            return null;
          },
        ));
      }
    }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final InAppWebViewController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse("http://localhost:8888/assets/charting_library/chart_white.html")),
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
        onWebViewCreated: (controller) {
          String script = "setEnvironment(\"AAA\", \"VI\");";
          controller.evaluateJavascript(source: script);
          _controller = controller;
        },
        onLoadStart: (controller, url) {
          print('loadStart ${url}');
        },
        onLoadStop: (controller, url) {
          String script = "setEnvironment(\"AAA\", \"VI\");";
          controller.evaluateJavascript(source: script);
          //_controller = controller;
          print('loadStop ${url}');
        },
        onConsoleMessage: (controller, message) {
          print('loadStop ${message.message}');
        },

      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          String script = "setEnvironment(\"AAA\", \"VI\");";
          _controller.evaluateJavascript(source: script);
        },
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
