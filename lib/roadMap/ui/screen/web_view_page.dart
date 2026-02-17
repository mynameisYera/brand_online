import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/roadMap/service/youtube_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final bool isAction;
  final int lessonId;
  final int actionId;
  const WebViewPage({super.key, required this.url, required this.isAction, required this.lessonId, required this.actionId});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }
  void _markWatched() {
    try {
      YoutubeService().materialsWatched(widget.lessonId, widget.actionId);
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Что-то пошло не так')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: widget.isAction ? FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          _markWatched();
        },
        child: Icon(Icons.check, color: Colors.white,),
      ) : null,
    );
    
  }
}
