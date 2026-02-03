import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../entity/SimpleTaskIndex.dart';


class ChaptersDialog extends StatefulWidget {
  final List<Map<SimpleTaskIndex, List<SimpleTaskIndex>>> data;

  const ChaptersDialog({super.key, required this.data});


  @override
  State<ChaptersDialog> createState() => _ChaptersDialogState();
}

class _ChaptersDialogState extends State<ChaptersDialog> with TickerProviderStateMixin {
  int expandedIndex = -1;
  int selectedChapterIndex = -1;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;


  @override
  void initState()  {
    super.initState();
    _controllers = List.generate(
      widget.data.length,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _animations = _controllers.map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut)).toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorList = [
      const Color.fromRGBO(75, 167, 255, 1.0),
      const Color.fromRGBO(141, 223, 84, 1.0),
      const Color.fromRGBO(211, 157, 255, 1.0),
      const Color.fromRGBO(255, 217, 66, 1.0),
      const Color.fromRGBO(255, 130, 85, 1.0),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Тараулар', style: TextStyles.bold(AppColors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.data.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedChapterIndex == index;
                  final isExpanded = expandedIndex == index;
                  final color = colorList[index % colorList.length];
                  final entry = widget.data[index].entries.first;
                  final chapterTitle = entry.key;
                  final lessonTitles = entry.value;
                  final isCompleted = chapterTitle.isCompleted;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                                      if (isExpanded) {
                                        _controllers[index].reverse();
                                        expandedIndex = -1;
                                      } else {
                                        if (expandedIndex != -1) {
                                          _controllers[expandedIndex].reverse();
                                        }
                                        expandedIndex = index;
                                        _controllers[index].forward();
                                      }
                                    });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10, top: 5),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.trueGreen.withOpacity(0.1) : Colors.white,
                            border: Border.all(color: AppColors.primaryBlue, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 0, left: 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Тарау ${chapterTitle.index}',
                                              style: TextStyles.semibold(
                                                AppColors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              chapterTitle.title,
                                              style: TextStyles.semibold(
                                                AppColors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10, right: 15, left: 20),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (expandedIndex != -1) {
                                                _controllers[expandedIndex].reverse();
                                              }
                                              Navigator.of(context).pop({
                                                'chapter': chapterTitle.title,
                                                'title': lessonTitles.first.title,
                                              });
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text("Алға", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined, color: AppColors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _animations[index],
                        axisAlignment: 1.0,
                        child: Container(
                          // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey),
                            borderRadius: BorderRadius.circular(15),
                            color: chapterTitle.isCompleted
                                ? AppColors.trueGreen.withOpacity(0.9)
                                : Colors.white
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(lessonTitles.length, (i) {
                              final isLessonCompleted = lessonTitles[i].isCompleted;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context, {
                                        'chapter': chapterTitle.title,
                                        'title': lessonTitles[i].title,
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isLessonCompleted
                                            ? Color(0xffEDFDF1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Сабақ ${lessonTitles[i].index}',
                                                        style: TextStyles.medium(
                                                          AppColors.black,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        lessonTitles[i].title,
                                                        style: TextStyles.medium(
                                                          AppColors.black,
                                                          fontSize: 16,
                                                        ),
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                            if (isLessonCompleted && !lessonTitles[i].isCashback)
                                              Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: Border.all(color: AppColors.trueGreen, width: 1),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: AppColors.trueGreen,
                                                    size: 15,
                                                  ),
                                                )
                                              ),
                                            if (lessonTitles[i].isCashback)
                                              Container(
                                                child: SvgPicture.asset('assets/icons/active_cashback.svg'),
                                              ),
                                              ],
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}