// lib/roadMap/ui/widgets/anagram_segments_input.dart
// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';

class AnagramSegmentsController extends ChangeNotifier {
  _AnagramSegmentsInputState? _state;

  void _attach(_AnagramSegmentsInputState s) => _state = s;
  void _detach(_AnagramSegmentsInputState s) {
    if (_state == s) _state = null;
  }

  bool get isComplete =>
      (_state?._answer.whereType<String>().length ?? 0) ==
          (_state?._requiredCount ?? 0);

  List<String> get selectedSegments =>
      List<String>.from(_state?._answer.whereType<String>() ?? const []);

  void reset(List<String> segments, int requiredCount) {
    _state?._reset(segments, requiredCount);
  }

  /// Локальная подсветка по позициям
  void checkAndHighlight(List<String> correctOrder) {
    _state?._checkAndHighlight(correctOrder);
  }
}

enum _SlotPaint { idle, correct, wrong }

class AnagramSegmentsInput extends StatefulWidget {
  final List<String> segments;
  final int requiredCount;
  final bool disabled;
  final bool isRepeat;
  final AnagramSegmentsController controller;

  const AnagramSegmentsInput({
    super.key,
    required this.segments,
    required this.requiredCount,
    required this.disabled,
    required this.isRepeat,
    required this.controller,
  });

  @override
  State<AnagramSegmentsInput> createState() => _AnagramSegmentsInputState();
}

class _AnagramSegmentsInputState extends State<AnagramSegmentsInput> {
  late List<String> _pool;
  late List<String?> _answer; // длина = requiredCount
  late List<_SlotPaint> _paint;
  late int _requiredCount;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _reset(widget.segments, widget.requiredCount);
  }

  @override
  void didUpdateWidget(covariant AnagramSegmentsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments ||
        oldWidget.requiredCount != widget.requiredCount) {
      _reset(widget.segments, widget.requiredCount);
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    super.dispose();
  }

  // ------ вызывается контроллером ------
  void _reset(List<String> segments, int requiredCount) {
    setState(() {
      _requiredCount = requiredCount;
      _pool = List<String>.from(segments);
      _answer = List<String?>.filled(requiredCount, null);
      _paint = List<_SlotPaint>.filled(requiredCount, _SlotPaint.idle);
      _checked = false;
    });
  }

  void _checkAndHighlight(List<String> correctOrder) {
    final correct = List<String>.from(correctOrder);
    setState(() {
      _checked = true;
      for (int i = 0; i < _answer.length; i++) {
        final u = _answer[i];
        final c = (i < correct.length) ? correct[i] : null;
        if (u != null && c != null && u == c) {
          _paint[i] = _SlotPaint.correct;
        } else {
          _paint[i] = _SlotPaint.wrong;
        }
      }
    });
  }
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    final base = widget.isRepeat ? Colors.orange : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Заголовок слотов (необязательно, но удобно визуально)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Жауап:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // --- СЛОТЫ
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: List.generate(_answer.length, (i) {
            final seg = _answer[i];

            // Цвета по состояниям
            Color border;
            Color fill;
            Color text;

            if (_checked) {
              switch (_paint[i]) {
                case _SlotPaint.correct:
                  border = Colors.green;
                  fill = Colors.green.withOpacity(.12);
                  text = Colors.green.shade800;
                  break;
                case _SlotPaint.wrong:
                  border = Colors.red;
                  fill = Colors.red.withOpacity(.10);
                  text = Colors.red.shade800;
                  break;
                case _SlotPaint.idle:
                  border = base;
                  fill = Colors.transparent;
                  text = Colors.black87;
                  break;
              }
            } else {
              if (seg == null) {
                border = Colors.grey.shade400;
                fill = Colors.grey.shade100;
                text = Colors.black38;
              } else {
                border = base;
                fill = base.withOpacity(.08); // ← выбранный слот — мягкий фон
                text = Colors.black87;
              }
            }

            return GestureDetector(
              onTap: widget.disabled || seg == null
                  ? null
                  : () {
                setState(() {
                  _pool.add(seg);
                  _answer[i] = null;
                  _checked = false;
                  _paint = List<_SlotPaint>.filled(
                      _paint.length, _SlotPaint.idle);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 1.6),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  child: seg == null
                      ? SizedBox(
                    key: ValueKey('empty_$i'),
                    width: 40,
                    height: 20,
                  )
                      : Text(
                    seg,
                    key: ValueKey(seg),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // --- Разделитель (пунктир)
        const _DashedDivider(),

        const SizedBox(height: 10),

        // --- Заголовок пула
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Сегменттер:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // --- ПУЛ СЕГМЕНТОВ
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_pool.length, (idx) {
            final seg = _pool[idx];
            return _segmentChip(
              seg: seg,
              base: base,
              disabled: widget.disabled,
              onTap: widget.disabled
                  ? null
                  : () {
                final slotIndex = _answer.indexWhere((e) => e == null);
                if (slotIndex == -1) return;
                setState(() {
                  _answer[slotIndex] = seg;
                  _pool.removeAt(idx);
                  _checked = false;
                  _paint = List<_SlotPaint>.filled(
                      _paint.length, _SlotPaint.idle);
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _segmentChip({
    required String seg,
    required Color base,
    required bool disabled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: base.withOpacity(.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: base, width: 1.4),
        ),
        child: Text(
          seg,
          style: TextStyle(
            fontSize: 15,
            color: disabled ? Colors.black45 : Colors.black87,
            fontWeight: FontWeight.w700, // ← читаемее
          ),
        ),
      ),
    );
  }
}

/// Пунктирная линия-разделитель между слотами и пулом
class _DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final Color? color;

  const _DashedDivider({
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.thickness = 1.2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade400;
    return CustomPaint(
      painter:
      _DashedLinePainter(color: c, dashWidth: dashWidth, dashSpace: dashSpace, thickness: thickness),
      size: const Size(double.infinity, 1),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double thickness;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.thickness != thickness;
  }
}
