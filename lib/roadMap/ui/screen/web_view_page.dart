import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/widgets/layout_widget.dart';
import 'package:brand_online/roadMap/service/youtube_service.dart';
import 'package:brand_online/roadMap/ui/screen/RoadMap.dart';
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
  bool _isLoading = false;

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Что-то пошло не так')));
    }
  }

  Future<void> _markWatchedWithDelay() async {
    setState(() => _isLoading = true);
    _markWatched();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RoadMap(initialScrollOffset: 0, selectedIndx: 0,state: 0,)));
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveWatermark(
      phone: "",
      userId: "",
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.primaryBlue,),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: widget.isAction
            ? FloatingActionButton(
                backgroundColor: AppColors.primaryBlue,
                onPressed: _isLoading ? null : _markWatchedWithDelay,
                child: const Icon(Icons.check, color: Colors.white),
              )
            : null,
      ),
      
    ); 
  }
}
