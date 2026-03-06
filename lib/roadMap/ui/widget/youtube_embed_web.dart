// Web-only: embeds YouTube video in the page via iframe.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';

/// Embeds a YouTube video on the page using an iframe (Flutter web only).
/// Use via conditional import with [YoutubeEmbedStub] on non-web.
class YoutubeEmbedWeb extends StatelessWidget {
  final String videoId;
  final double aspectRatio;

  const YoutubeEmbedWeb({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: HtmlElementView.fromTagName(
        tagName: 'iframe',
        onElementCreated: (Object element) {
          final iframe = element as html.IFrameElement;
          iframe.src =
              'https://www.youtube-nocookie.com/embed/$videoId?autoplay=1';
          iframe.referrerPolicy = 'strict-origin-when-cross-origin';
          iframe.style.border = 'none';
          iframe.style.width = '100%';
          iframe.style.height = '100%';
          iframe.style.display = 'block';
          iframe.allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
          iframe.allowFullscreen = true;
        },
      ),
    );
  }
}
