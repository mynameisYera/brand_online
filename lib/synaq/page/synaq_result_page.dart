import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/roadMap/entity/ControlExam.dart';
import 'package:brand_online/roadMap/entity/TaskEntity.dart';
import 'package:brand_online/roadMap/ui/screen/RoadMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SynaqResultPage extends StatefulWidget {
  final MockExamTasksResponse answer;

  const SynaqResultPage({super.key, required this.answer});

  @override
  State<SynaqResultPage> createState() => _SynaqResultPageState();
}

class _SynaqResultPageState extends State<SynaqResultPage> {
  MockExam get exam => widget.answer.exam;
  MockExamAttempt get attempt => exam.attempt;

  static String _answerDisplay(Map<String, dynamic>? map, Task task) {
    if (map == null || map.isEmpty) return '—';
    if (task.taskType == 'multiple-choice') {
      if (map.containsKey('content')) return map['content']?.toString() ?? '—';
      final choiceId = map['choice_id'];
      if (choiceId != null && task.choices.isNotEmpty) {
        final list = task.choices.where((c) => c.id == choiceId).toList();
        if (list.isNotEmpty) return list.first.content;
      }
      return '—';
    }
    if (task.taskType == 'fill-in-the-blank' && map.containsKey('answer')) {
      return map['answer']?.toString() ?? '—';
    }
    if (task.taskType == 'matching-pairs') {
      if (map.containsKey('pairs') && map['pairs'] is List) {
        final pairs = map['pairs'] as List;
        return pairs.map((p) {
          if (p is! Map) return '';
          final l = p['left_content']?.toString() ?? '?';
          final r = p['right_content']?.toString() ?? '?';
          return '$l ↔ $r';
        }).where((s) => s.isNotEmpty).join(', ');
      }
      if (map.containsKey('matches') && map['matches'] is List && task.matchingPairs != null) {
        final mp = task.matchingPairs!;
        final leftById = {for (final e in mp.leftItems) e.id: e.content};
        final rightById = {for (final e in mp.rightItems) e.id: e.content};
        final pairs = (map['matches'] as List).map((m) {
          if (m is! Map) return '?';
          final lid = m['left_id'];
          final rid = m['right_id'];
          return '${leftById[lid] ?? '?'} ↔ ${rightById[rid] ?? '?'}';
        }).toList();
        return pairs.join(', ');
      }
    }
    if (task.taskType == 'anagram') {
      if (map.containsKey('segments') && map['segments'] is List) {
        final seg = (map['segments'] as List).map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
        if (seg.isNotEmpty) return seg.join(' ');
      }
      if (map.containsKey('answer')) return map['answer']?.toString() ?? '—';
    }
    if (map.containsKey('content')) return map['content']?.toString() ?? '—';
    if (map.containsKey('answer')) return map['answer']?.toString() ?? '—';
    return '—';
  }

  TagExtension _mathExtension() => TagExtension(
    tagsToExtend: {'span'},
    builder: (ctx) {
      final formula = ctx.innerHtml.replaceAll(r'\(', '').replaceAll(r'\)', '');
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Math.tex(
          formula,
          mathStyle: MathStyle.text,
          textStyle: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      );
    },
  );

  Widget _contentWidget(String text, TextStyle style) {
    if (text.isEmpty || text == '—') return Text('—', style: style);
    if (text.contains('<') || text.contains('&')) {
      return Html(
        data: text,
        shrinkWrap: true,
        style: {'*': Style(fontSize: FontSize(style.fontSize ?? 14), color: style.color ?? AppColors.black, fontFamily: 'Manrope', fontFamilyFallback: ['Roboto'])},
        extensions: [_mathExtension()],
      );
    }
    return Text(text, style: style);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = attempt.percentage.clamp(0.0, 100.0);
    final progress = percentage / 100.0;
    Color headerColor = AppColors.primaryBlue;
    if (progress < 0.5) headerColor = const Color(0xffFF6700);
    else if (progress < 0.7) headerColor = AppColors.yellow;

    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                 SizedBox(
                    height: 30,
                  ),
                Text(
                  exam.title,
                  style: TextStyles.bold(AppColors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${exam.gradeName} · ${exam.subjectName}',
                  style: TextStyles.medium(AppColors.white.withOpacity(0.95), fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 1,
                        backgroundColor: AppColors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyles.bold(AppColors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${attempt.correctCount} / ${attempt.answeredCount} дұрыс',
                  style: TextStyles.medium(AppColors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: widget.answer.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.answer.tasks[index];
                final answerList = widget.answer.answers.where((a) => a.taskId == task.id).toList();
                final answer = answerList.isNotEmpty ? answerList.first : null;
                final isCorrect = answer?.isCorrect ?? false;
                final userStr = answer != null ? _answerDisplay(answer.userAnswer, task) : '—';
                var correctStr = answer != null ? _answerDisplay(answer.correctAnswer, task) : '—';
                if (task.taskType == 'anagram' && correctStr == '—' && task.anagramAnswer.isNotEmpty) {
                  correctStr = task.anagramAnswer.join(' ');
                }

                return Card(
                  color: AppColors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? AppColors.trueGreen : AppColors.errorRed,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Сұрақ ${index + 1}',
                                style: TextStyles.semibold(AppColors.black, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _contentWidget(
                          task.content,
                          TextStyles.regular(AppColors.black, fontSize: 15),
                        ),
                        if (answer != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Сіздің жауабыңыз:', style: TextStyles.medium(AppColors.grey, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    _contentWidget(
                                      userStr,
                                      TextStyles.medium(isCorrect ? AppColors.trueGreen : AppColors.errorRed, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isCorrect)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Дұрыс жауап:', style: TextStyles.medium(AppColors.grey, fontSize: 12)),
                                      const SizedBox(height: 2),
                                      _contentWidget(
                                        correctStr,
                                        TextStyles.medium(AppColors.trueGreen, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Артқа',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RoadMap(selectedIndx: 1, state: 0)),
                    (route) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
