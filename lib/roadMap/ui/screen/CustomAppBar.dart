import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../authorization/entity/ProfileResponse.dart';
import '../../../authorization/service/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../general/GeneralUtil.dart';
import '../../entity/ProfileController.dart';
import '../../entity/SubjectModel.dart';

import '../widget/HowCashbackCalculatedScreen.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  // static const String _howCalcUrl =
  //     'https://youtu.be/eujigBLxbLY?feature=shared';

  late ProfileResponse response = ProfileResponse(
    permanent_balance: 0,
    temporary_balance: 0,
    id: 1,
    role: 0,
    grade: 0,
    strike: "0",
    points: "0",
    multiplier: "0",
    selectedGrade: null,
    permanentBalance: 0,
    temporaryBalance: 0,
    gradeBalances: [],
  );

  List<SubjectModel> myCourses = [];

  // final _storage = const FlutterSecureStorage();

  final List<Color> colors = [
    Color.fromRGBO(75, 167, 255, 1.0),
    Color.fromRGBO(141, 223, 84, 1.0),
    Color.fromRGBO(211, 157, 255, 1.0),
    Color.fromRGBO(255, 217, 66, 1.0),
    Color.fromRGBO(255, 130, 85, 1.0),
  ];

  @override
  void initState() {
    super.initState();
    getProfile();
    getMyCourses();
  }

  Future<void> getMyCourses() async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio _dio = Dio(BaseOptions(baseUrl: GeneralUtil.BASE_URL));
    try {
      final response = await _dio.get(
        '/edu/my-courses/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          myCourses = (response.data as List)
              .map((item) => SubjectModel.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      print("Ошибка при получении курсов: $e");
    }
  }

  getProfile() async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    String? token = await storage.read(key: 'auth_token');

    AuthService()
        .getProfile(token!, context)
        .then((res) => {
              if (res != null)
                {
                  ProfileController.updateFromProfile(res),
                  response = res,
                  savePreferences(res.points),
                }
              else
                {
                  print('ERROR'),
                }
            })
        .then(
          (value) => {
            setState(() {
              print(response);
            }),
          },
        );
  }

  void savePreferences(String accessToken) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    await storage.write(key: 'points', value: accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset("assets/images/star.png", width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text(
                    response.points,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset("assets/images/fire.png", width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text(
                    response.strike,
                    style: TextStyle(
                      color: GeneralUtil.orangeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Text(
                "x${response.multiplier}",
                style: TextStyle(
                  color: GeneralUtil.mainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: () => _showCashbackTopSheet(context),
                child: Row(
                  children: [
                    Text(
                      "${response.permanentBalance}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCashbackTopSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'cashback',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, child) {
        final curved = Curves.easeOut.transform(anim.value);
        return Opacity(
          opacity: curved,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.black38),
              ),
              Transform.translate(
                offset: Offset(0, -300 + 300 * curved),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Material(
                        color: Colors.white,
                        elevation: 8,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Апталық кэшбек',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Column(
                                children: response.gradeBalances.map((balance) {
                                  return _buildCashbackRow(
                                    balance.subjectName,
                                    '${balance.temporaryBalance}',
                                  );
                                }).toList(),
                              ),

                              const Divider(height: 32),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${response.temporaryBalance}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Ссылка
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pop(); // закрыть TopSheet
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const HowCashbackCalculatedScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'қалай есептеледі?',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCashbackRow(String subject, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject, style: const TextStyle(fontSize: 16)),
          Text(amount, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> setGrade(int gradeId) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio dio = Dio(BaseOptions(baseUrl: GeneralUtil.BASE_URL));
    try {
      await dio.post(
        '/edu/my-courses/set-grade/$gradeId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print("Ошибка при установке класса: $e");
    }
  }

  // ignore: unused_element
  Widget _subjectChip(
      String grade, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              grade,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
