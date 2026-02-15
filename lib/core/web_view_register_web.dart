import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

/// Registers [WebWebViewPlatform] for Flutter web so youtube_player_iframe (and other WebView usage) works.
void registerWebViewForPlatform() {
  WebViewPlatform.instance = WebWebViewPlatform();
}
