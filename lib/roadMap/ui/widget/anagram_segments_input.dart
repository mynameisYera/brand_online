// lib/roadMap/ui/widgets/anagram_segments_input.dart
// ignore_for_file: unused_element_parameter, unused_local_variable
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
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
    final base = widget.isRepeat ? Colors.orange : Color(0xFF4CA3FF); // Light blue

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 20),
        //   child: Text(
        //     'Сәйкестендір',
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontSize: 20,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(_answer.length, (i) {
            final seg = _answer[i];

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
                border = Colors.grey.shade300;
                fill = Colors.grey.shade100;
                text = Colors.transparent;
              } else {
                border = base;
                fill = base.withOpacity(0.2);
                text = Colors.black87;
              }
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
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
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                decoration: BoxDecoration(
                  color: Color(0xffC5E5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: base, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff0082FF),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  seg ?? '',
                  style: TextStyles.bold(Color(0xff0082FF), fontSize: 18),
                ),
              ),
            );
          }),
        ),
        Divider(),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
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
        SizedBox(height: 20),

        GestureDetector(
          onTap: widget.disabled
              ? null
              : () {
            final allSegments = List<String>.from(widget.segments);
            for (var seg in _answer) {
              if (seg != null && !allSegments.contains(seg)) {
                allSegments.add(seg);
              }
            }
            _reset(allSegments, widget.requiredCount);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Қайта таңдау',
                style: TextStyles.medium(AppColors.grey, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.refresh,
                size: 18,
                color: widget.disabled ? AppColors.grey : AppColors.grey,
              ),
            ],
          ),
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
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xffC5E5FF), // Light blue background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: base, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Color(0xff0082FF),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          seg,
          style: TextStyles.bold(Color(0xff0082FF), fontSize: 18),
        ),
      ),
    );
  }
}
