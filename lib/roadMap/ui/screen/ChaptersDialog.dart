import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text("Тақырыптар", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                    ],
                  ),
                ],
              ),
            ),
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => selectedChapterIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
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
                                        padding: const EdgeInsets.only(right: 15, left: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Тарау ${chapterTitle.index}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 4), // расстояние между строками
                                            Text(
                                              chapterTitle.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text("Алға", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  color: Colors.white,
                                ),
                                GestureDetector(
                                  onTap: () {
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
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.article, color: Colors.white, size: 50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _animations[index],
                        axisAlignment: 1.0,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            children: List.generate(lessonTitles.length, (i) => Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context, {
                                      'chapter': chapterTitle.title,
                                      'title': lessonTitles[i].title,
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Сабақ ${lessonTitles[i].index}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 4), // расстояние между строками
                                          Text(
                                            lessonTitles[i].title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (i < lessonTitles.length - 1)
                                  SizedBox(
                                    width: double.infinity,
                                    child: Divider(
                                      color: Colors.white,
                                      thickness: 3,
                                      height: 1,
                                    ),
                                  ),
                              ],
                            )),
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