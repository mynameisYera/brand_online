import 'dart:ui';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/service/display_chacker.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/news/ui/NotificationsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
      width: DisplayChacker.isDisplay(context) ? double.infinity : 600,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(1, 4),
                    ),
                  ],
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/fire.svg", width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text(
                      response.strike,
                      style: TextStyles.medium(AppColors.black)
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(1, 4),
                    ),
                  ],
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/point.svg", width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text(
                      response.points,
                      style: TextStyles.medium(AppColors.black)
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(1, 4),
                    ),
                  ],
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "X", style: TextStyles.bold(AppColors.primaryBlue, fontSize: 13)),
                          TextSpan(text: response.multiplier, style: TextStyles.medium(AppColors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () => _showCashbackTopSheet(context),
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(1, 4),
                    ),
                  ],
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "₸ ", style: TextStyles.bold(AppColors.trueGreen, fontSize: 20)),
                          TextSpan(text: "${response.permanentBalance}", style: TextStyles.medium(AppColors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(1, 4),
                      ),
                    ],
                    color: AppColors.secondaryBlue,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: SvgPicture.asset("assets/icons/notification.svg", width: 20, height: 20),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                ),
              )
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
                                  Text('Апталық кэшбек', style: TextStyles.bold(AppColors.black)),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.close, color: AppColors.grey),
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
                                    '${balance.temporaryBalance}₸',
                                  );
                                }).toList(),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('', style: TextStyles.semibold(AppColors.black)),
                                  Text(
                                    '${response.temporaryBalance}₸',
                                    style: TextStyles.semibold(AppColors.errorRed).copyWith(fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const HowCashbackCalculatedScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'қалай есептеледі?',
                                    style: TextStyles.medium(
                                      AppColors.primaryBlue,
                                      fontSize: 13,
                                    ).copyWith(decoration: TextDecoration.underline),
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
          Text(subject, style: TextStyles.semibold(AppColors.black)),
          Text(amount, style: TextStyles.semibold(AppColors.black)),
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
