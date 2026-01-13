import 'dart:io';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:brand_online/profile/service/profile_service.dart';
import 'package:brand_online/profile/ui/BalanceScreen.dart';
import 'package:brand_online/roadMap/ui/screen/subscription_page.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../general/GeneralUtil.dart';
import '../entity/StudentProfile.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StudentProfile? profile;
  bool isLoading = true;
  String formattedPhone = '';
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  bool deletingProfile = false;
  @override
  @override
  void initState() {
    super.initState();
    _initWithSplashDelay();
  }

  Future<void> _initWithSplashDelay() async {
    setState(() => isLoading = true);

    final fetch = ProfileService().getStudentProfile();
    final delay = Future.delayed(const Duration(seconds: 0));

    final result = await Future.wait([fetch, delay]);

    final data = (result[0] != null) ? result[0] as StudentProfile : null;
    setState(() {
      profile = data;
      if (profile?.curator?.username != null) {
        formattedPhone = profile!.curator!.username.startsWith('8')
            ? profile!.curator!.username.replaceFirst('8', '+7')
            : profile!.curator!.username;
      } else {
        formattedPhone = '';
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || profile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Center(
            child: LoadingAnimationWidget.progressiveDots(
              color: GeneralUtil.mainColor,
              size: MediaQuery.of(context).size.width * 0.2,
            ),
          ),
        )
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
              ),
              child: Center(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Text(
                    '${profile!.firstName} ${profile!.lastName}',
                    style: TextStyles.bold(Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(profile!.username, style: TextStyles.regular(Colors.white)),
                ],
              ),
            ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 130,
                      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 21.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/icons/fire.svg'),
                          const SizedBox(height: 5),
                          Text('${profile!.strike}', style: TextStyles.bold(AppColors.black)),
                          Text('Страйк', style: TextStyles.regular(AppColors.black, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(
                      height: 130,
                      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 21.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/icons/point.svg'),
                          const SizedBox(height: 5),
                          Text('${profile!.points}', style: TextStyles.bold(AppColors.black)),
                          Text('Ұпай', style: TextStyles.regular(AppColors.black, fontSize: 10)),
                        ],
                      ),
                    ),

                Container(
                  height: 130,
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 21.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/icons/multiplayer.svg'),
                      const SizedBox(height: 5),
                      Text('${profile!.points}', style: TextStyles.bold(AppColors.black)),
                      Text('Көбейткіш', style: TextStyles.regular(AppColors.black, fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
            // const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _iconText("assets/images/users.png", GeneralUtil.yellowColor, 'Топ\n${profile!.group?.name}'),
            //   ],
            // ),
            const SizedBox(height: 20),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffFFCC00),
                    Color(0xffFF8D28),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: SvgPicture.asset('assets/icons/primer.svg')),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Premium жазылым', style: TextStyles.medium(Colors.white)),
                      const SizedBox(height: 5),
                      Text('${profile!.daysLeft} күн қалды', style: TextStyles.regular(Colors.white)),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),

            SizedBox(height: 16),

                Platform.isAndroid ? SizedBox() : profile!.daysLeft == 0 ? Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  SubscriptionPage()));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Подписка сатып алу',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    const SizedBox(height: 10),
                  ],
                ) : SizedBox(),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BalanceScreen(currentBalance: profile!.permanent_balance),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: SvgPicture.asset('assets/icons/gift.svg')),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Бонус', style: TextStyles.medium(AppColors.black)),
                            Text('${profile!.permanent_balance} ұпай', style: TextStyles.regular(AppColors.grey)),
                          ],
                        ),
                        Spacer(),
                        Row(
                            children: [
                              Text(
                                'Өтінім беру',
                                style: TextStyles.medium(AppColors.primaryBlue, fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios, color: AppColors.primaryBlue, size: 16),
                            ],
                          ),
                      ],
                    ),
                  )
                ),
                const SizedBox(height: 20),

                if (profile != null && profile!.curator != null) ...[
                  Text('Ментор', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  _curatorBox(
                    "${profile!.curator?.lastName} ${profile!.curator?.firstName}",
                    GeneralUtil.pinkColor,
                    "https://wa.me/${(formattedPhone)}",
                  ),
                  const SizedBox(height: 20),
                ],
                Text('Менің курстарым', style: TextStyles.medium(AppColors.black)),
                const SizedBox(height: 10),
                Column(
                  children: [
                    ...profile!.grades.map((grade) {
                      return _courseTag('${grade.gradeName} ${grade.subject}', AppColors.primaryBlue);
                    }),
                  ],
                ),
                
                const SizedBox(height: 10),
                Text('Бізбен байланыс', style: TextStyles.medium(AppColors.black)),
                const SizedBox(height: 10),
                _contactLink(FontAwesomeIcons.instagram, profile!.contactLinks.instagram.name, profile!.contactLinks.instagram.link, Color(0xffEC9CCC)),
                _contactLink(Icons.telegram, profile!.contactLinks.telegram.name, profile!.contactLinks.telegram.link, Color(0xff90CAF9)),
                _contactLink(FontAwesomeIcons.whatsapp, profile!.contactLinks.whatsapp.name, profile!.contactLinks.whatsapp.link, Color(0xffA6E4AD)),
                const SizedBox(height: 20),
                ButtonWidget(
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppColors.errorRed),
                      SizedBox(width: 8),
                      Text('Жүйеден шығу', style: TextStyles.medium(AppColors.errorRed, fontSize: 16)),
                    ],
                  ), 
                  color: Colors.white, 
                  textColor: AppColors.errorRed, 
                  onPressed: () => showLogoutConfirmationSheet(context), 
                  borderColor: AppColors.errorRed
                ),
                const SizedBox(height: 10),
                ButtonWidget(
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: AppColors.white),
                      SizedBox(width: 8),
                      Text('Профильді өшіру', style: TextStyles.medium(AppColors.white, fontSize: 16)),
                    ],
                  ), 
                  color: AppColors.errorRed, 
                  textColor: AppColors.white, 
                  onPressed: () => showDeleteConfirmationSheet(context), 
                  borderColor: AppColors.white
                ),
              ],
            ),
            )
          ],
        ),
      ),
    );
  }

void showLogoutConfirmationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сіз сенімдісіз бе?',
              style: TextStyles.bold(AppColors.black, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Сіз аккаунттан шығуды растайсыз ба?',
              style: TextStyles.regular(AppColors.black, fontSize: 14),
            ),

            const SizedBox(height: 24),
            ButtonWidget(
              widget: Text('ШЫҒУ', style: TextStyles.bold(AppColors.white, fontSize: 16)),
              color: AppColors.errorRed,
              textColor: AppColors.white,
              onPressed: () async {
                Navigator.pop(context);
                await logoutUser();
                Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
              },
              borderColor: AppColors.errorRed
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Артқа қайту',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      );
    },
  );
}

void showDeleteConfirmationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Сіз профильіңізді өшіретініңізге сенімдісіз бе?',
              style: TextStyles.bold(AppColors.black, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Сіздің барлық жетістіктеріңіз жоғалады.',
              style: TextStyles.regular(AppColors.black, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ButtonWidget(
              widget: Text('ӨШІРУ', style: TextStyles.bold(AppColors.white, fontSize: 16)),
              color: AppColors.errorRed,
              textColor: AppColors.white,
              onPressed: () async {
                setState(() {
                  deletingProfile  = true;
                });
                Navigator.pop(context);
                await logoutUser();
                ProfileService().deleteProfile();
                Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
              },
              borderColor: AppColors.errorRed
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Артқа қайту', style: TextStyles.regular(AppColors.primaryBlue, fontSize: 14))),
            const SizedBox(height: 15),
          ],
        ),
      );
    },
  );
}

  Future<void> logoutUser() async {
    await _storage.deleteAll();
  }


  Widget _curatorBox(String name, Color color, String url) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('$name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _courseTag(String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(label, style: TextStyles.medium(Colors.white)),)
    );
  }

  Widget _contactLink(IconData icon, String name, String url, Color color) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 204, 204, 204), width: 1),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(color: AppColors.black, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}