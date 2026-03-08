// Stub for non-web. Real implementation is [YoutubeEmbedWeb] (web only).
import 'package:flutter/material.dart';

class YoutubeEmbedWebController {
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> playbackRateNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> durationNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isFullscreenNotifier = ValueNotifier<bool>(false);

  void play() {}

  void pause() {}

  void setPlaybackRate(double rate) {
    playbackRateNotifier.value = rate;
  }

  void seekToProgress(double progress) {
    progressNotifier.value = progress.clamp(0.0, 1.0);
  }

  void toggleFullscreen() {
    isFullscreenNotifier.value = !isFullscreenNotifier.value;
  }

  void dispose() {
    isPlayingNotifier.dispose();
    playbackRateNotifier.dispose();
    progressNotifier.dispose();
    durationNotifier.dispose();
    isFullscreenNotifier.dispose();
  }
}

/// Stub: not used on non-web. On web, use [YoutubeEmbedWeb] via conditional import.
class YoutubeEmbedWeb extends StatelessWidget {
  final String videoId;
  final double aspectRatio;
  final bool fillParent;
  final YoutubeEmbedWebController? controller;

  const YoutubeEmbedWeb({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
    this.fillParent = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
