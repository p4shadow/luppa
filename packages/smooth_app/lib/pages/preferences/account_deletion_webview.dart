import 'package:flutter/material.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AccountDeletionWebview extends StatefulWidget {
  const AccountDeletionWebview({required this.userId, super.key});

  final String userId;

  @override
  State<AccountDeletionWebview> createState() => _AccountDeletionWebviewState();
}

class _AccountDeletionWebviewState extends State<AccountDeletionWebview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params =
          WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
          );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params =
          AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
          );
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..loadRequest(_getUri());
  }

  Uri _getUri() => Uri.parse('https://world.luppa.ar/editor/${widget.userId}');

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: SmoothAppBar(),
      body: WebViewWidget(controller: _controller),
    );
  }
}
