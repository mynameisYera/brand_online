import 'package:flutter/material.dart';

class DailyReviewTile extends StatefulWidget {
  const DailyReviewTile({
    super.key,
    required this.subject,
    required this.onStart,
    required this.isCompleted,
    this.title = 'Күнделікті қайталау',
    this.mascotAsset = 'assets/images/SHOQAN.png',
    this.mascotAsset2 = 'assets/images/admbrs12.png',
  });

  final String subject;
  final String title;
  final String mascotAsset;
  final String mascotAsset2;
  final VoidCallback onStart;
  final bool isCompleted;

  @override
  State<DailyReviewTile> createState() => _DailyReviewTileState();
}

class _DailyReviewTileState extends State<DailyReviewTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const start = Color(0xFF9E77FF);
    const end = Color(0xFFB58CFF);
    const primary = Color(0xFF1D61E7);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (!widget.isCompleted) setState(() => _expanded = !_expanded);
      },
      child: Container(
        height: 146,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [start, end],
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subject.isNotEmpty ? widget.subject : 'Пән',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: -5,
              bottom: -10,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  widget.mascotAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned(
              left: 12,
              bottom: 12,
              child: Row(
                children: [
                  _CompletionBadge(completed: widget.isCompleted),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (c, a) =>
                        FadeTransition(opacity: a, child: c),
                    child: _expanded
                        ? OutlinedButton.icon(
                            key: const ValueKey('cta'),
                            onPressed: widget.onStart,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            icon: const Text(
                              'Кеттік!',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: primary, width: 1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  size: 16, color: primary),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final bg = completed
        ? Colors.white.withOpacity(.95)
        : Colors.white.withOpacity(.25);
    final border =
        completed ? Colors.white.withOpacity(.0) : Colors.white.withOpacity(.7);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      alignment: Alignment.center,
      child: completed
          ? const Icon(Icons.check_rounded, size: 24, color: Color(0xFF7F5CFF))
          : const SizedBox.shrink(),
    );
  }
}
