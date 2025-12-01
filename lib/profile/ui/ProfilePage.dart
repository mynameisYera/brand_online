import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40,),
            Center(child: Text('Профиль', style: TextStyle(fontWeight: FontWeight.w500))),
            SizedBox(height: 20,),
            Center(
              child: Column(
                children: [
                  Text(
                    '${profile!.firstName} ${profile!.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(profile!.username),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoBox2("assets/images/fire1.png", '${profile!.strike}\nСтрайк', GeneralUtil.darkBlueColor),
                _infoBox('${profile!.points}\nҰпай', GeneralUtil.darkBlueColor),
                _infoBox('x${profile!.multiplier}\nКөбейткіш', GeneralUtil.darkBlueColor),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconText("assets/images/users.png", GeneralUtil.yellowColor, 'Топ\n${profile!.group?.name}'),
                _iconText("assets/images/subscribe.png", GeneralUtil.orangeColor, 'Подписка\n${profile!.daysLeft} күн'),
              ],
            ),
            const SizedBox(height: 20),

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
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Бонус ${profile!.permanent_balance}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                        children: const [
                          Text(
                            'өтінім беру',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
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
            Text('Менің курстарым', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Center(
              child: Wrap(
                spacing: 30,
                runSpacing: 20,
                children: profile!.grades.map((grade) {
                  final color = _getColorForGrade(grade.gradeId);
                  return _courseTag('${grade.gradeName}\n${grade.subject}', color);
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
            Text('Бізбен байланыс', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _contactLink(FontAwesomeIcons.instagram, profile!.contactLinks.instagram.name, profile!.contactLinks.instagram.link),
            _contactLink(Icons.telegram, profile!.contactLinks.telegram.name, profile!.contactLinks.telegram.link),
            _contactLink(FontAwesomeIcons.whatsapp, profile!.contactLinks.whatsapp.name, profile!.contactLinks.whatsapp.link),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16, top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.orange),
                  label: const Text(
                    'Жүйеден шығу',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  onPressed:() => showLogoutConfirmationSheet(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Профильді өшіру',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  onPressed:() => showDeleteConfirmationSheet(context),
                ),
              ),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Сіз сенімдісіз бе?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await logoutUser();
                  Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ШЫҒУ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'АРТҚА',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
            const Text(
              'Сіз профильіңізді өшіретініңізге сенімдісіз бе?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  
                  setState(() {
                    deletingProfile  = true;
                  });
                  Navigator.pop(context);
                  logoutUser();
                  ProfileService().deleteProfile();
                  Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: (deletingProfile) ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2,
                  ),) : const Text(
                  'ӨШІРУ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'АРТҚА',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

  Future<void> logoutUser() async {
    await _storage.deleteAll();
  }


  Widget _infoBox(String label, Color color) {
    final parts = label.split('\n');
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
      width: 100,
      decoration: BoxDecoration(
        color: GeneralUtil.yellowOrangeColor.withOpacity(1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                parts[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            parts[1],
            style: TextStyle(color: GeneralUtil.blackColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _infoBox2(String icon, String label, Color color) {
    final parts = label.split('\n');
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
      width: 100,
      decoration: BoxDecoration(
        color: GeneralUtil.yellowOrangeColor.withOpacity(1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 24),
              const SizedBox(width: 4),
              Text(
                parts[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            parts[1],
            style: TextStyle(color: GeneralUtil.blackColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _iconText(String icon, Color color, String label) {
    final parts = label.split('\n');
    return Column(
      children: [
        Image.asset(icon, color: color, width: 50, height: 50,),
        const SizedBox(height: 4),
        Text(parts[0],
            style: TextStyle(fontWeight: FontWeight.bold, color: GeneralUtil.mainColor,fontSize: 25)),
        Text((parts[1] == "null") ? '-' : parts[1],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
      ],
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _contactLink(IconData icon, String name, String url) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Color _getColorForGrade(int id) {
    final List<Color> colors = [
      GeneralUtil.pinkColor,
      GeneralUtil.greenColor,
      GeneralUtil.orangeColor,
      GeneralUtil.redColor,
      GeneralUtil.mainColor,
    ];
    return colors[id % colors.length];
  }
}