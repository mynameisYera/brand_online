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

        final fontSize = width * 0.016;

        final columns = (width / 200).ceil();
        final rows = (height / 100).ceil();

        final displayPhone = _phone.isNotEmpty ? _phone : widget.phone;
        final text = "$displayPhone\n @brand-online.kz";

        return Stack(
          children: [
            widget.child,

            IgnorePointer(
              child: Opacity(
                opacity: 0.07,
                child: Column(
                  children: List.generate(rows, (row) {
                    return Row(
                      children: List.generate(columns, (col) {
                        return Expanded(
                          child: Transform.rotate(
                            angle: -pi / 6,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
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