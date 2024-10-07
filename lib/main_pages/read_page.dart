import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:read_zone/theme.dart'; // Import your theme
import 'package:read_zone/components/navbar.dart'; // Import your Navbar

class ReadPage extends StatefulWidget {
  final String title;
  final String url;

  const ReadPage({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor, // Use primaryColor from theme.dart
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black), // Black foreground for contrast
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 2, // Set current index to 2 for the read page
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}