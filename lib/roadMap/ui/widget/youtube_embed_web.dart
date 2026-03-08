// Web-only: embeds YouTube video in the page via iframe.
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';

import 'package:flutter/material.dart';

class YoutubeEmbedWebController {
  html.IFrameElement? _iframe;
  StreamSubscription<html.MessageEvent>? _messageSubscription;
  Timer? _progressTimer;
  bool _isAttached = false;
  bool _isReady = false;
  bool _awaitingDurationResponse = false;
  final List<Map<String, dynamic>> _pendingCommands = <Map<String, dynamic>>[];
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> playbackRateNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> durationNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isFullscreenNotifier = ValueNotifier<bool>(false);

  void attachIframe(html.IFrameElement iframe) {
    _iframe = iframe;
    if (!_isAttached) {
      _isAttached = true;
      _setupMessageListener();
    }
  }

  void onIframeLoaded() {
    _isReady = true;
    _initApiBridge();
    _flushPendingCommands();
  }

  void play() {
    _postCommand('playVideo');
    isPlayingNotifier.value = true;
    _startProgressPolling();
  }

  void pause() {
    _postCommand('pauseVideo');
    isPlayingNotifier.value = false;
    _stopProgressPolling();
  }

  void setPlaybackRate(double rate) {
    _postCommand('setPlaybackRate', <dynamic>[rate]);
    playbackRateNotifier.value = rate;
  }

  void seekToProgress(double progress) {
    final duration = durationNotifier.value;
    if (duration <= 0) return;
    final seconds = (progress.clamp(0.0, 1.0) * duration);
    _postCommand('seekTo', <dynamic>[seconds, true]);
    progressNotifier.value = progress.clamp(0.0, 1.0);
  }

  void toggleFullscreen() {
    final iframe = _iframe;
    if (iframe == null) return;
    final inFullScreen = html.document.fullscreenElement != null;
    if (inFullScreen) {
      html.document.exitFullscreen();
      isFullscreenNotifier.value = false;
    } else {
      iframe.requestFullscreen();
      isFullscreenNotifier.value = true;
    }
  }

  void dispose() {
    _progressTimer?.cancel();
    _messageSubscription?.cancel();
    isPlayingNotifier.dispose();
    playbackRateNotifier.dispose();
    progressNotifier.dispose();
    durationNotifier.dispose();
    isFullscreenNotifier.dispose();
  }

  void _postCommand(String func, [List<dynamic> args = const <dynamic>[]]) {
    final payload = <String, dynamic>{
      'event': 'command',
      'func': func,
      'args': args,
      'id': 'yt-web-player',
    };
    if (!_isReady || _iframe == null) {
      _pendingCommands.add(payload);
      return;
    }
    final message = jsonEncode(payload);
    _iframe!.contentWindow?.postMessage(message, '*');
  }

  void _initApiBridge() {
    _postRaw(<String, dynamic>{
      'event': 'listening',
      'id': 'yt-web-player',
      'channel': 'widget',
    });
    _postCommand('addEventListener', <dynamic>['onStateChange']);
    _postCommand('addEventListener', <dynamic>['onPlaybackRateChange']);
    _postCommand('getDuration');
    _postCommand('getCurrentTime');
  }

  void _setupMessageListener() {
    _messageSubscription = html.window.onMessage.listen((event) {
      final data = event.data;
      Map<String, dynamic>? message;

      if (data is num) {
        _handleNumericMessage(data.toDouble());
        return;
      }

      if (data is String) {
        final asNum = double.tryParse(data);
        if (asNum != null) {
          _handleNumericMessage(asNum);
          return;
        }
      }

      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            message = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      } else if (data is Map) {
        message = Map<String, dynamic>.from(data);
      }

      if (message == null) return;
      _handleMessage(message);
    });
  }

  void _handleMessage(Map<String, dynamic> message) {
    final event = message['event'] as String?;
    if (event == 'onStateChange') {
      final state = message['data'] as int?;
      if (state == null) return;
      final playing = state == 1;
      isPlayingNotifier.value = playing;
      if (playing) {
        _startProgressPolling();
      } else {
        _stopProgressPolling();
      }
      return;
    }

    if (event == 'onPlaybackRateChange') {
      final rate = (message['data'] as num?)?.toDouble();
      if (rate != null) {
        playbackRateNotifier.value = rate;
      }
      return;
    }

    if (event == 'infoDelivery') {
      final info = message['info'];
      if (info is! Map) return;
      final infoMap = Map<String, dynamic>.from(info);
      final duration = (infoMap['duration'] as num?)?.toDouble();
      final currentTime = (infoMap['currentTime'] as num?)?.toDouble();
      final rate = (infoMap['playbackRate'] as num?)?.toDouble();

      if (duration != null && duration > 0) {
        durationNotifier.value = duration;
      }
      if (rate != null) {
        playbackRateNotifier.value = rate;
      }
      if (currentTime != null) {
        final total = durationNotifier.value;
        if (total > 0) {
          progressNotifier.value = (currentTime / total).clamp(0.0, 1.0);
        }
      }
    }
  }

  void _startProgressPolling() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _awaitingDurationResponse = true;
      _postCommand('getDuration');
      Future<void>.delayed(const Duration(milliseconds: 70), () {
        _awaitingDurationResponse = false;
        _postCommand('getCurrentTime');
      });
    });
  }

  void _stopProgressPolling() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _handleNumericMessage(double value) {
    if (_awaitingDurationResponse || durationNotifier.value <= 0) {
      if (value > 0) {
        durationNotifier.value = value;
      }
      return;
    }

    final total = durationNotifier.value;
    if (total > 0) {
      progressNotifier.value = (value / total).clamp(0.0, 1.0);
    }
  }

  void _postRaw(Map<String, dynamic> payload) {
    if (!_isReady || _iframe == null) {
      _pendingCommands.add(payload);
      return;
    }
    _iframe!.contentWindow?.postMessage(jsonEncode(payload), '*');
  }

  void _flushPendingCommands() {
    if (!_isReady || _iframe == null || _pendingCommands.isEmpty) return;
    for (final command in _pendingCommands) {
      _iframe!.contentWindow?.postMessage(jsonEncode(command), '*');
    }
    _pendingCommands.clear();
  }
}

/// Embeds a YouTube video on the page using an iframe (Flutter web only).
/// Use via conditional import with [YoutubeEmbedStub] on non-web.
class YoutubeEmbedWeb extends StatelessWidget {
  final String videoId;
  final double aspectRatio;
  final YoutubeEmbedWebController? controller;

  const YoutubeEmbedWeb({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: HtmlElementView.fromTagName(
        tagName: 'iframe',
        onElementCreated: (Object element) {
          final iframe = element as html.IFrameElement;
          iframe.onLoad.listen((_) {
            controller?.onIframeLoaded();
          });
          iframe.src =
              'https://www.youtube.com/embed/$videoId?autoplay=1&controls=0&rel=0&modestbranding=1&iv_load_policy=3&disablekb=1&fs=0&playsinline=1&enablejsapi=1&widgetid=1&origin=${Uri.base.origin}';
          iframe.referrerPolicy = 'strict-origin-when-cross-origin';
          iframe.style.border = 'none';
          iframe.style.width = '100%';
          iframe.style.height = '100%';
          iframe.style.display = 'block';
          iframe.style.pointerEvents = 'none';
          iframe.allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
          iframe.allowFullscreen = true;
          controller?.attachIframe(iframe);
        },
      ),
    );
  }
}
