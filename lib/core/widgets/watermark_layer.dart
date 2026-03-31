import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdaptiveWatermark extends StatefulWidget {
  final Widget child;
  final String phone;
  final String userId;

  const AdaptiveWatermark({
    super.key,
    required this.child,
    required this.phone,
    required this.userId,
  });

  @override
  State<AdaptiveWatermark> createState() => _AdaptiveWatermarkState();
}

class _AdaptiveWatermarkState extends State<AdaptiveWatermark> {
  late Timer _timer;
  String currentTime = "";
  String _phone = "";

  @override
  void initState() {
    super.initState();
    _phone = widget.phone;
    _loadPhoneIfNeeded();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updateTime();
    });
  }

  Future<void> _loadPhoneIfNeeded() async {
    if (!_needsStoragePhone(_phone)) {
      return;
    }
    final storedPhone = await FlutterSecureStorage().read(key: 'phone');
    if (!mounted) {
      return;
    }
    if (storedPhone != null && storedPhone.isNotEmpty) {
      setState(() {
        _phone = storedPhone;
      });
    }
  }

  bool _needsStoragePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return true;
    }
    return trimmed.contains('X') || trimmed.contains('x') || trimmed.contains('*');
  }

  @override
  void didUpdateWidget(covariant AdaptiveWatermark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phone != oldWidget.phone) {
      _phone = widget.phone;
      _loadPhoneIfNeeded();
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime =
        "${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute}";
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final shortestSide = min(width, height);
        final isPhone = shortestSide < 700;

        // Make watermark readable on phones and softer on larger screens.
        final fontSize = isPhone
            ? (shortestSide * 0.035).clamp(12.0, 18.0)
            : (width * 0.016).clamp(13.0, 22.0);

        final tileWidth = isPhone ? 150.0 : 220.0;
        final tileHeight = isPhone ? 85.0 : 120.0;
        final columns = max(1, (width / tileWidth).ceil());
        final rows = max(1, (height / tileHeight).ceil());
        final watermarkOpacity = isPhone ? 0.12 : 0.07;
        final watermarkAngle = isPhone ? -pi / 7 : -pi / 6;
        final watermarkPadding = isPhone ? 12.0 : 20.0;

        final displayPhone = _phone.isNotEmpty ? _phone : widget.phone;
        final text = "$displayPhone\n @brand-online.kz";

        return Stack(
          children: [
            widget.child,

            IgnorePointer(
              child: Opacity(
                opacity: watermarkOpacity,
                child: Column(
                  children: List.generate(rows, (row) {
                    return Row(
                      children: List.generate(columns, (col) {
                        return Expanded(
                          child: Transform.rotate(
                            angle: watermarkAngle,
                            child: Padding(
                              padding: EdgeInsets.all(watermarkPadding),
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}