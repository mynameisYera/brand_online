import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class JustAudioBar extends StatefulWidget {
  final String url;
  final Color? accent;
  const JustAudioBar({super.key, required this.url, this.accent});

  @override
  State<JustAudioBar> createState() => _JustAudioBarState();
}

class _JustAudioBarState extends State<JustAudioBar> {
  final _player = AudioPlayer();
  Duration _pos = Duration.zero, _dur = Duration.zero, _buf = Duration.zero;
  bool _playing = false;

  Color get _accent => widget.accent ?? Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();


    _player.playerStateStream.listen((s) {
      setState(() => _playing = s.playing);
    });
    _player.durationStream.listen((d) {
      if (d != null) setState(() => _dur = d);
    });
    _player.positionStream.listen((p) => setState(() => _pos = p));
    _player.bufferedPositionStream.listen((b) => setState(() => _buf = b));
  }

  @override
  void didUpdateWidget(covariant JustAudioBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {

      _player.stop();
      _player.seek(Duration.zero);
      setState(() {
        _pos = Duration.zero;
        _dur = Duration.zero;
        _buf = Duration.zero;
        _playing = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _playOrPause() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    try {
      await _player.setUrl(widget.url);
      await _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аудио ашылмады')),
      );
    }
  }

  Future<void> _seekRelative(int seconds) async {
    if (_dur == Duration.zero) return;
    final t = _pos + Duration(seconds: seconds);
    final clamped = t < Duration.zero ? Duration.zero : (t > _dur ? _dur : t);
    await _player.seek(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _dur.inMilliseconds;
    final v = totalMs == 0 ? 0.0 : _pos.inMilliseconds / totalMs;
    final vb = totalMs == 0 ? 0.0 : _buf.inMilliseconds / totalMs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Stack(
          alignment: Alignment.centerLeft,
          children: [

            FractionallySizedBox(
              widthFactor: vb.clamp(0.0, 1.0),
              child: Container(height: 2, color: _accent.withOpacity(0.2)),
            ),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                activeTrackColor: _accent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: _accent,
              ),
              child: Slider(
                value: v.clamp(0.0, 1.0),
                onChanged: (nv) {
                  if (totalMs == 0) return;
                  final target =
                  Duration(milliseconds: (totalMs * nv).round());
                  _player.seek(target);
                },
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_pos),
                  style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.bold,)),
              Text(_fmt(_dur),
                  style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.bold,)),
            ],
          ),
        ),

        const SizedBox(height: 6),


        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: '-10s',
              splashRadius: 20,
              iconSize: 22,
              color: _accent,
              icon: const Icon(Icons.replay_10),
              onPressed: () => _seekRelative(-10),
            ),
            IconButton(
              tooltip: _playing ? 'Pause' : 'Play',
              splashRadius: 26,
              iconSize: 30,
              color: _accent,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              onPressed: _playOrPause,
            ),
            IconButton(
              tooltip: '+10s',
              splashRadius: 20,
              iconSize: 22,
              color: _accent,
              icon: const Icon(Icons.forward_10),
              onPressed: () => _seekRelative(10),
            ),
          ],
        ),
      ],
    );
  }
}
