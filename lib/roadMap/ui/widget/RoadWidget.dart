import 'package:flutter/material.dart';

import '../../../authorization/entity/RoadMapResponse.dart';
import '../../../general/GeneralUtil.dart';
import '../screen/Math1Screen.dart';
import '../screen/RoadMap.dart';
import '../screen/YoutubeScreen.dart';

class RoadWidget {
  void showWatchVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  const Text(
                    'Ескерту!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: GeneralUtil.orangeColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Алдымен видеосабақ көру қажет',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: GeneralUtil.blackColor,
                    ),
                  ),
                  const SizedBox(height: 50),

                  /// Картинка
                  Image.asset(
                    'assets/images/admbarys.png', // проверь путь в pubspec.yaml
                    height: 179,
                    fit: BoxFit.contain,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'ТҮСІНІКТІ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Кнопка, немного заходящая на картинку
            // Positioned(
            //   bottom: 40,
            //   child: SizedBox(
            //     // width: MediaQuery.sizeOf(context).width * 0.6,
            //     height: 48,
            //     child: ElevatedButton(
            //       onPressed: () => Navigator.pop(context),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.blue,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //       ),
            //       child: const Text(
            //         'ТҮСІНІКТІ!',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //           fontSize: 16,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            /// Иконка закрытия (крестик)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showUndefinedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 60), // оставляем место под кнопку
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  const Text(
                    'Ескерту!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500, // соответствует 500
                      fontSize: 24,
                      height: 1.0, // 100% line height
                      letterSpacing: 0.0,
                      color: GeneralUtil.orangeColor, // или Colors.black87
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Бұл сабақ ашылмаған',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400, // соответствует 500
                      fontSize: 20,
                      height: 1.0, // 100% line height
                      letterSpacing: 0.0,
                      color: GeneralUtil.blackColor, // или Colors.black87
                    ),
                  ),
                  const SizedBox(height: 50),

                  /// Картинка
                  Image.asset(
                    'assets/images/admbarys.png', // проверь путь в pubspec.yaml
                    height: 179,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'ТҮСІНІКТІ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // /// Кнопка, немного заходящая на картинку
            // Positioned(
            //   bottom: 40,
            //   child: SizedBox(
            //     width: MediaQuery.sizeOf(context).width * 0.6,
            //     height: 48,
            //     child: 
            //   ),
            // ),

            /// Иконка закрытия (крестик)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showTaskDoneDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  const Text(
                    'Ескерту!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      height: 1.0, // 100% line height
                      letterSpacing: 0.0,
                      color: GeneralUtil.orangeColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Алдыңғы тапсырма орындалмады',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      height: 1.0, // 100% line height
                      letterSpacing: 0.0,
                      color: GeneralUtil.blackColor,
                    ),
                  ),
                  const SizedBox(height: 50),

                  /// Картинка
                  Image.asset(
                    'assets/images/admbarys.png',
                    height: 179,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 40,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.6,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'ТҮСІНІКТІ!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> playDialogScreen(
      BuildContext context, int index, GlobalKey key, Lesson lesson, {
        double scrollOffset = 0.0,
      }) async {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    bool watched = await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Barrier",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),

              Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(position.dx - 100, position.dy - 120),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: colors[index % 5],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Видео сабақ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),

                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YoutubeScreen(lesson: lesson),
                              ),
                            );
                            await Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoadMap(initialScrollOffset: scrollOffset, selectedIndx: 0,state: 0,),
                                ),
                                    (route) => false,
                              );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Кеттік !",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors[index % 5],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ) ?? false; // Если диалог был закрыт вручную, возвращаем false

    return watched;
  }

  Future<bool> math1(BuildContext context, int index, GlobalKey key,
      Lesson lesson, int groupId, bool isRight , {
        double scrollOffset = 0.0,
      }) async {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    bool watched = await showGeneralDialog(
      context: context,
      barrierDismissible: true, // Закрытие при нажатии вне окна
      barrierLabel: "Barrier",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),

              Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset( (isRight) ? position.dx - 70 : position.dx - 120, position.dy - 120),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: colors[index % 5],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lesson.lessonTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Math1Screen(
                                  initialScrollOffset: scrollOffset,
                                  lessonId: lesson.lessonId,
                                  groupId: groupId,
                                  cashbackActive: lesson.cashbackActive,
                                  isCash: false,
                                  lesson: lesson,
                                ),
                              ),
                            ) ?? false;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoadMap(initialScrollOffset: scrollOffset, selectedIndx: 0,state: 0,),
                                ),
                                    (route) => false,
                              );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Кеттік!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors[index % 5],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ) ?? false; // Если диалог был закрыт вручную, возвращаем false

    return watched;
  }

  Widget roadFromLeft(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.3),
              child: _buildCircularButton('assets/images/math_icon.png'),
            ),
            SizedBox(
              height: 20,
            ),
            _buildCircularButton('assets/images/math_icon.png'),
            SizedBox(
              height: 20,
            ),
            _buildCircularButton('assets/images/math_icon.png'),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.3),
              child: _buildCircularButton('assets/images/play_icon.png'),
            ),
          ],
        ),
        // Stars Row
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(Icons.star,
                    color: index < 2 ? Colors.yellow : Colors.grey, size: 24);
              }),
            ),
            SizedBox(height: 5),
            // Robot Image
            Image.asset(
              'assets/images/robot_image.png',
              // Replace with actual asset
              width: 100,
              height: 150,
            ),
          ],
        ),
      ],
    );
  }

  Widget roadFromRight(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stars Row
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(Icons.star,
                    color: index < 2 ? Colors.yellow : Colors.grey, size: 24);
              }),
            ),
            SizedBox(height: 5),
            // Robot Image
            Image.asset(
              'assets/images/robot_image.png',
              // Replace with actual asset
              width: 100,
              height: 150,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.3),
              child: _buildCircularButton('assets/images/math_icon.png'),
            ),
            SizedBox(
              height: 20,
            ),
            _buildCircularButton('assets/images/math_icon.png'),
            SizedBox(
              height: 20,
            ),
            _buildCircularButton('assets/images/math_icon.png'),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.3),
              child: _buildCircularButton('assets/images/play_icon.png'),
            ),
          ],
        )
      ],
    );
  }



  Widget _buildCircularButton(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.yellow,
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 70,
          height: 70,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _spaceBreaker(
    String text,
    double d,
  ) {
    return SizedBox(
      width: d,
      child: Row(
        children: [
          Flexible(
            child: Divider(
              color: Colors.grey,
              thickness: 1,
              endIndent: 10, // Space between line and text
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10, // Space between line and text
            ),
          ),
        ],
      ),
    );
  }

  List<Color> colors = [
    Color.fromRGBO(75, 167, 255, 1.0),
    Color.fromRGBO(141, 223, 84, 1.0),
    Color.fromRGBO(211, 157, 255, 1.0),
    Color.fromRGBO(255, 217, 66, 1.0),
    Color.fromRGBO(255, 130, 85, 1.0),
  ];
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(10, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
