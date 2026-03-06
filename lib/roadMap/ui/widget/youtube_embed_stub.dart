// Stub for non-web. Real implementation is [YoutubeEmbedWeb] (web only).
import 'package:flutter/material.dart';

/// Stub: not used on non-web. On web, use [YoutubeEmbedWeb] via conditional import.
class YoutubeEmbedWeb extends StatelessWidget {
  final String videoId;
  final double aspectRatio;

  const YoutubeEmbedWeb({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
