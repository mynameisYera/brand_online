import 'package:flutter/material.dart';
import '../../../roadMap/entity/TaskEntity.dart';

// Публичный enum для покраски слотов (если понадобится снаружи)
enum AnagramSlotState { idle, correct, wrong }

/// Контроллер, чтобы TaskWidget мог:
/// - сбросить анаграмму (reset)
/// - проверить локально и подсветить (checkAndHighlight)
/// - получить готовность (isComplete) и порядок item_id (orderIds)
class AnagramController extends ChangeNotifier {
  _AnagramInputState? _state;

  bool get isAttached => _state != null;

  void _attach(_AnagramInputState s) => _state = s;
  void _detach(_AnagramInputState s) {
    if (_state == s) _state = null;
  }

  bool get isComplete => _state?._answerSlots.every((e) => e != null) ?? false;

  List<int> get orderIds =>
      (_state?._answerSlots ?? [])
          .whereType<AnagramItem>()
          .map((e) => e.itemId)
          .toList();

  void reset(List<AnagramItem> items) {
    _state?._reset(items);
  }

  /// Локальная проверка (подсветка слотов по позициям)
  void checkAndHighlight(List<AnagramItem> correctItems) {
    _state?._checkAndHighlight(correctItems);
  }
}

/// Виджет анаграммы: верх — слоты, низ — пул букв.
/// Внешний код управляется через [controller].
class AnagramInput extends StatefulWidget {
  final List<AnagramItem> items;       // исходный пул (в порядке с бэка)
  final AnagramController controller;  // внешний контроллер
  final bool disabled;                 // блокировка ввода (во время submit или на "ЖАЛҒАСТЫРУ")
  final bool isRepeat;                 // для базового цвета (оранж/синий)

  const AnagramInput({
    super.key,
    required this.items,
    required this.controller,
    required this.disabled,
    required this.isRepeat,
  });

  @override
  State<AnagramInput> createState() => _AnagramInputState();
}

class _AnagramInputState extends State<AnagramInput> {
  late List<AnagramItem> _pool;             // низ
  late List<AnagramItem?> _answerSlots;     // верх
  late List<AnagramSlotState> _slotStates;  // покраска после проверки
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _reset(widget.items);
  }

  @override
  void didUpdateWidget(covariant AnagramInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _reset(widget.items);
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    super.dispose();
  }

  // ---------- public (через controller) ----------
  void _reset(List<AnagramItem> items) {
    setState(() {
      _pool = List<AnagramItem>.from(items);
      _answerSlots = List<AnagramItem?>.filled(_pool.length, null);
      _slotStates =
      List<AnagramSlotState>.filled(_pool.length, AnagramSlotState.idle);
      _checked = false;
    });
  }

  void _checkAndHighlight(List<AnagramItem> correctItems) {
    final correct = [...correctItems]..sort((a, b) => a.itemId.compareTo(b.itemId));
    setState(() {
      _checked = true;
      for (int i = 0; i < _answerSlots.length; i++) {
        final u = _answerSlots[i];
        final c = (i < correct.length) ? correct[i] : null;
        if (u != null && c != null && u.itemId == c.itemId) {
          _slotStates[i] = AnagramSlotState.correct;
        } else {
          _slotStates[i] = AnagramSlotState.wrong;
        }
      }
    });
  }
  // ----------------------------------------------

  @override
  Widget build(BuildContext context) {
    final base = widget.isRepeat ? Colors.orange : Colors.blue;

    return Column(
      children: [
        // Верх — слоты ответа
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: List.generate(_answerSlots.length, (i) {
            final item = _answerSlots[i];
            final st = _slotStates[i];

            Color border = base;
            Color fill = Colors.transparent;
            if (_checked) {
              if (st == AnagramSlotState.correct) {
                border = Colors.green;
                fill = Colors.green.withOpacity(.12);
              } else if (st == AnagramSlotState.wrong) {
                border = Colors.red;
                fill = Colors.red.withOpacity(.12);
              }
            }

            return GestureDetector(
              onTap: widget.disabled || item == null
                  ? null
                  : () {
                setState(() {
                  _pool.add(item);
                  _answerSlots[i] = null;
                  _checked = false;
                  _slotStates = List<AnagramSlotState>.filled(
                    _slotStates.length,
                    AnagramSlotState.idle,
                  );
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 1.8),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 140),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: item == null
                      ? SizedBox(
                    key: ValueKey('empty_$i'),
                    width: 22,
                    height: 22,
                  )
                      : Text(
                    item.content,
                    key: ValueKey('slot_${item.itemId}'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Низ — пул букв
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_pool.length, (idx) {
            final item = _pool[idx];
            return _letterChip(
              text: item.content,
              base: base,
              keyVal: 'pool_${item.itemId}',
              disabled: widget.disabled,
              onTap: widget.disabled
                  ? null
                  : () {
                // ближайший пустой слот
                final slotIndex =
                _answerSlots.indexWhere((e) => e == null);
                if (slotIndex == -1) return;
                setState(() {
                  _answerSlots[slotIndex] = item;
                  _pool.removeAt(idx);
                  _checked = false;
                  _slotStates = List<AnagramSlotState>.filled(
                    _slotStates.length,
                    AnagramSlotState.idle,
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _letterChip({
    required String text,
    required Color base,
    required String keyVal,
    required bool disabled,
    VoidCallback? onTap,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: ValueKey(keyVal),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: base.withOpacity(.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: base, width: 1.6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: disabled ? Colors.black45 : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
