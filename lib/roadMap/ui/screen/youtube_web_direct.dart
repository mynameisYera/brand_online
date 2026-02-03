// ignore_for_file: unused_field, unnecessary_null_comparison
import 'package:brand_online/general/GeneralUtil.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:async';
import 'dart:convert';
import '../../../../core/loggers/l.dart';
import '../../../authorization/entity/RoadMapResponse.dart';
import '../../service/youtube_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class YoutubeWebDirect extends StatefulWidget {
  final Lesson lesson;

  const YoutubeWebDirect({super.key, required this.lesson});

  @override
  State<YoutubeWebDirect> createState() => _YoutubeWebDirectState();
}

class _YoutubeWebDirectState extends State<YoutubeWebDirect> {
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showControls = true; 
  String? _videoId;
  final String _viewId = 'youtube-iframe-direct';
  bool _isExpanded = false;
  
  double _currentTime = 0.0;
  double _duration = 0.0;
  bool _isSliderDragging = false;
  Timer? _progressTimer;
  Timer? _controlsTimer; 
  html.IFrameElement? _iframe;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.lesson.videoUrl);
    _registerIframe();
    _setupMessageListener();
    _duration = 300.0;
    _startControlsTimer(); 
    L.info('Video', 'Инициализация прямого YouTube плеера для веб: ${widget.lesson.lessonTitle}');
    L.l('Video ID: $_videoId');
  }



  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startControlsTimer();
  }

  void _registerIframe() {
    if (_videoId != null && _videoId!.isNotEmpty) {
      _addHiddenCSS();
      
      _iframe = html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$_videoId?autoplay=0&rel=0&showinfo=0&modestbranding=1&controls=0&disablekb=1&fs=0&iv_load_policy=3&cc_load_policy=0&color=white&theme=dark&playsinline=1&loop=0&mute=0&enablejsapi=1&origin=${Uri.base.origin}&start=0'
        ..style.border = 'none'
        ..allowFullscreen = true 
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
        ..width = '100%'
        ..height = '100%'
        ..style.borderRadius = '8px'
        ..style.overflow = 'hidden'
        ..style.pointerEvents = 'none'
        ..id = _viewId
        ..onLoad.listen((_) {
          Timer(const Duration(seconds: 2), () {
            _setupYouTubePlayer();
          });
        });

      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => _iframe!,
      );
    }
  }

  void _setupMessageListener() {
    html.window.addEventListener('message', (html.Event event) {
      final html.MessageEvent messageEvent = event as html.MessageEvent;
      
      try {
        final data = messageEvent.data;
        
        if (data is String) {
          final Map<String, dynamic> message = json.decode(data);
          _handleYouTubeMessage(message);
        } else if (data is Map) {
          final message = Map<String, dynamic>.from(data);
          _handleYouTubeMessage(message);
        } else if (data is num) {
          if (!_isSliderDragging && mounted) {
            setState(() {
              if (_duration == 0 || _duration == 300.0) {
                _duration = data.toDouble();
              } else {
                _currentTime = data.toDouble();
              }
            });
          }
        }
      } catch (e) {
        
      }
    });
  }

  void _setupYouTubePlayer() {
    if (_iframe == null) return;
    
    final setupMessage = json.encode({
      "event": "listening",
      "id": _viewId,
      "channel": "widget"
    });
    _iframe!.contentWindow?.postMessage(setupMessage, '*');
    
    Timer(const Duration(milliseconds: 500), () {
      if (mounted && _iframe != null) {
        final stateMessage = json.encode({
          "event": "command",
          "func": "addEventListener",
          "args": ["onStateChange"]
        });
        _iframe!.contentWindow?.postMessage(stateMessage, '*');
        
        Timer(const Duration(milliseconds: 500), () {
          if (mounted && _iframe != null) {
            final durationMessage = json.encode({
              "event": "command",
              "func": "getDuration",
              "args": []
            });
            _iframe!.contentWindow?.postMessage(durationMessage, '*');
          }
        });
      }
    });
  }

  void _handleYouTubeMessage(Map<String, dynamic> message) {
    if (!mounted) return;
    
    final event = message['event'] as String?;
    
    if (event == 'onStateChange') {
      final state = message['data'] as int?;
      if (state != null) {
        setState(() {
          _isPlaying = state == 1;
        });
        
        if (state == 1) {
          _startProgressTracking();
          _startControlsTimer(); 
        } else if (state == 2) {
          _progressTimer?.cancel();
          _controlsTimer?.cancel(); 
          setState(() {
            _showControls = true; 
          });
        }
      }
    } else if (event == 'infoDelivery') {
      final info = message['info'] as Map<String, dynamic>?;
      if (info != null) {
        final currentTime = (info['currentTime'] as num?)?.toDouble();
        final duration = (info['duration'] as num?)?.toDouble();
        
        if (!_isSliderDragging) {
          setState(() {
            if (currentTime != null) _currentTime = currentTime;
            if (duration != null && duration > 0) _duration = duration;
          });
        }
      }
    }
  }

  void _addHiddenCSS() {
    final styleElement = html.StyleElement();
    styleElement.text = '''
      
      iframe#$_viewId {
        pointer-events: none !important;
        user-select: none !important;
        -webkit-user-select: none !important;
        -moz-user-select: none !important;
        -ms-user-select: none !important;
      }
      
      
      .video-overlay {
        position: absolute !important;
        top: 0 !important;
        left: 0 !important;
        right: 0 !important;
        bottom: 0 !important;
        background: transparent !important;
        z-index: 999 !important;
        pointer-events: auto !important;
      }
      
      
      .ytp-chrome-bottom,
      .ytp-pause-overlay,
      .ytp-show-cards-title,
      .ytp-watermark,
      .ytp-youtube-button,
      .ytp-fullscreen-button,
      .ytp-settings-button,
      .ytp-subtitles-button,
      .ytp-volume-panel,
      .ytp-progress-bar,
      .ytp-time-display,
      .ytp-play-button,
      .ytp-title,
      .ytp-share-button,
      .ytp-endscreen-element,
      .ytp-ce-element,
      .ytp-cards-teaser,
      .ytp-info-panel,
      .ytp-videowall-still,
      .ytp-suggestion-set,
      .ytp-endscreen-content {
        display: none !important;
        opacity: 0 !important;
        visibility: hidden !important;
        pointer-events: none !important;
      }
      
      
      .ytp-title-link,
      .ytp-title-channel,
      .ytp-watch-later-button,
      .ytp-share-button-visible {
        display: none !important;
        pointer-events: none !important;
      }
      
      
      .expanded-video {
        width: 100vw !important;
        height: 100vh !important;
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        z-index: 999999 !important;
        object-fit: contain !important;
        background: black !important;
        border-radius: 0 !important;
      }
      
      
      .expanded-container {
        width: 100vw !important;
        height: 100vh !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        background: black !important;
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        z-index: 999999 !important;
      }
      
      
      .expanded-controls {
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        right: 0 !important;
        bottom: 0 !important;
        z-index: 10000 !important;
        pointer-events: none !important;
      }
      
      .expanded-controls .controls-content {
        pointer-events: auto !important;
      }
      
      
      @media (max-width: 768px) {
        .expanded-video {
          width: 100vw !important;
          height: 100vh !important;
          position: fixed !important;
          top: 0 !important;
          left: 0 !important;
          z-index: 999999 !important;
          object-fit: contain !important;
          background: black !important;
        }
      }
    ''';
    html.document.head?.append(styleElement);
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _lastUpdateTime = DateTime.now();
      }
    });
    
    if (_iframe != null) {
      if (_isPlaying) {
        _iframe!.contentWindow?.postMessage('{"event":"command","func":"playVideo","args":[]}', '*');
        _startProgressTracking();
        _startControlsTimer();
      } else {
        _iframe!.contentWindow?.postMessage('{"event":"command","func":"pauseVideo","args":[]}', '*');
        _progressTimer?.cancel();
        _controlsTimer?.cancel();
        setState(() {
          _showControls = true;
        });
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _showControls = true;
    });
    _startControlsTimer();
  }

  void _seekTo(double seconds) {
    if (_iframe != null) {
      final message = json.encode({
        "event": "command",
        "func": "seekTo",
        "args": [seconds, true]
      });
      _iframe!.contentWindow?.postMessage(message, '*');
    }
  }

  String _formatDuration(double seconds) {
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return _buildExpandedVideo();
    }
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  widget.lesson.lessonTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _videoId != null && _videoId!.isNotEmpty
                      ? _buildVideoContainer()
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                "Ошибка загрузки видео",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Не удалось извлечь ID видео",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _markVideoAsWatched,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: LoadingAnimationWidget.progressiveDots(
                                  color: GeneralUtil.mainColor,
                                  size: 100,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Жүктелуде...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "ТҮСІНІКТІ!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            _showControlsTemporarily();
          },
          child: Stack(
            children: [
              _buildIframeWidget(),
              
              
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (_showControls) {
                      _togglePlayPause();
                    } else {
                      _showControlsTemporarily();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),

              
              if (_showControls && !_isPlaying)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),

              
              if (_showControls && !_isExpanded)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        Row(
                          children: [
                            Text(
                              _formatDuration(_currentTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.blue,
                                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                                  thumbColor: Colors.blue,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  trackHeight: 4,
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: _duration > 0 ? (_currentTime / _duration).clamp(0.0, 1.0) : 0.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentTime = value * _duration;
                                      _isSliderDragging = true;
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    _seekTo(value * _duration);
                                    setState(() {
                                      _isSliderDragging = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            
                            _buildControlButton(
                              icon: Icons.replay_10,
                              onPressed: () {
                                final newTime = (_currentTime - 10).clamp(0.0, _duration);
                                _seekTo(newTime);
                                _showControlsTemporarily();
                              },
                              size: 32,
                            ),
                            
                            
                            _buildControlButton(
                              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                              onPressed: () {
                                _togglePlayPause();
                                _showControlsTemporarily();
                              },
                              size: 40,
                              isMain: true,
                            ),
                            
                            
                            _buildControlButton(
                              icon: Icons.forward_10,
                              onPressed: () {
                                final newTime = (_currentTime + 10).clamp(0.0, _duration);
                                _seekTo(newTime);
                                _showControlsTemporarily();
                              },
                              size: 32,
                            ),
                            
                            _buildControlButton(
                              icon: _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                              onPressed: () {
                                _toggleExpanded();
                                _showControlsTemporarily();
                              },
                              size: 32,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              
              if (_showControls && _isExpanded)
                _buildExpandedControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isMain ? 60 : 50,
        height: isMain ? 60 : 50,
        decoration: BoxDecoration(
          color: isMain ? Colors.blue.withOpacity(0.8) : Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }

  Widget _buildExpandedControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Row(
              children: [
                Text(
                  _formatDuration(_currentTime),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.blue,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                    ),
                    child: Slider(
                      value: _duration > 0 ? (_currentTime / _duration).clamp(0.0, 1.0) : 0.0,
                      onChanged: (value) {
                        setState(() {
                          _currentTime = value * _duration;
                          _isSliderDragging = true;
                        });
                      },
                      onChangeEnd: (value) {
                        _seekTo(value * _duration);
                        setState(() {
                          _isSliderDragging = false;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                _buildFullscreenControlButton(
                  icon: Icons.replay_10,
                  onPressed: () {
                    final newTime = (_currentTime - 10).clamp(0.0, _duration);
                    _seekTo(newTime);
                    _showControlsTemporarily();
                  },
                  size: 40,
                ),
                
                
                _buildFullscreenControlButton(
                  icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                  onPressed: () {
                    _togglePlayPause();
                    _showControlsTemporarily();
                  },
                  size: 50,
                  isMain: true,
                ),
                
                
                _buildFullscreenControlButton(
                  icon: Icons.forward_10,
                  onPressed: () {
                    final newTime = (_currentTime + 10).clamp(0.0, _duration);
                    _seekTo(newTime);
                    _showControlsTemporarily();
                  },
                  size: 40,
                ),
                
                _buildFullscreenControlButton(
                  icon: Icons.fullscreen_exit,
                  onPressed: () {
                    _toggleExpanded();
                    _showControlsTemporarily();
                  },
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isMain ? 80 : 60,
        height: isMain ? 80 : 60,
        decoration: BoxDecoration(
          color: isMain ? Colors.blue.withOpacity(0.9) : Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }

  Widget _buildIframeWidget() {
    return HtmlElementView(
      viewType: _viewId,
      onPlatformViewCreated: (int id) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      },
    );
  }

  Widget _buildExpandedVideo() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Видео на весь экран
          Positioned.fill(
            child: _videoId != null && _videoId!.isNotEmpty
                ? _buildExpandedVideoContainer()
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Ошибка загрузки видео",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Не удалось извлечь ID видео",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
          
          // Кнопка закрытия
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, size: 30, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
              },
            ),
          ),
          
          // Элементы управления
          if (_showControls)
            _buildExpandedControls(),
        ],
      ),
    );
  }

  Widget _buildExpandedVideoContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        child: GestureDetector(
          onTap: () {
            _showControlsTemporarily();
          },
          child: Stack(
            children: [
              _buildIframeWidget(),
              
              // Оверлей для управления
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (_showControls) {
                      _togglePlayPause();
                    } else {
                      _showControlsTemporarily();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),

              // Центральная кнопка play/pause
              if (_showControls && !_isPlaying)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_iframe != null && mounted && _isPlaying && !_isSliderDragging) {
        final message = json.encode({
          "event": "command",
          "func": "getVideoData",
          "args": []
        });
        _iframe!.contentWindow?.postMessage(message, '*');
        
        final timeMessage = json.encode({
          "event": "command", 
          "func": "getCurrentTime",
          "args": []
        });
        _iframe!.contentWindow?.postMessage(timeMessage, '*');
        
        final durationMessage = json.encode({
          "event": "command",
          "func": "getDuration", 
          "args": []
        });
        _iframe!.contentWindow?.postMessage(durationMessage, '*');
      }
    });
  }

  String? _extractVideoId(String url) {
    final RegExp regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^\"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    final Match? match = regExp.firstMatch(url);
    final videoId = match != null ? match.group(1) : null;

    if (videoId == null || videoId.isEmpty) {
      L.error('youtube', 'ссылка некорректна: $url');
    } else {
      L.l('ссылка корректна: $url');
    }

    return videoId;
  }

  void _markVideoAsWatched() {
    if (_isLoading) return;

    L.info('pressed', 'ТҮСІНІКТІ: ${widget.lesson.lessonTitle}');

    setState(() {
      _isLoading = true;
    });

    YoutubeService().videoWatched(widget.lesson.lessonId).then((res) {
      if (!mounted) return;

      if (res != null && res.message == "Lesson marked as watched.") {
        L.success('Video', 'Урок отмечен как просмотренный: ${widget.lesson.lessonTitle}');
        setState(() {
          widget.lesson.videoWatched = true;
        });
        Navigator.of(context).pop(true);
      } else {
        L.error('Video', 'Ошибка при отметке урока как просмотренного: ${res?.message}');
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      if (!mounted) return;

      L.error('Video', 'Response error: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }
}