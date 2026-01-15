import 'dart:io';
import 'package:brand_online/authorization/ui/screen/LoginScreen.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/roadMap/ui/screen/RoadMap.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:brand_online/core/notification/firebase_utils.dart';
import 'package:brand_online/core/subscription_service.dart';
import 'package:brand_online/firebase_options.dart';
import 'package:brand_online/pursache/purchase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('kk_KZ');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUtil().initialize();
  Platform.isIOS ? await PurchasesConfig.init() : print("android");
  runApp(const Application());
}


class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  bool? isTokenValid;
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    checkToken();
    Platform.isIOS ? _initializeServices() : print('android');
  }

  Future<void> _initializeServices() async {
    await SubscriptionService().initialize();
  }

  Future<void> checkToken() async {
    print('[TokenCheck] Started');

    final savedAtString = await _storage.read(key: 'auth_saved_at');
    final token = await _storage.read(key: 'auth_token');

    print('[TokenCheck] savedAt: $savedAtString');
    print('[TokenCheck] token: $token');

      if (savedAtString != null && token != null && token.isNotEmpty) {
        final savedAt = DateTime.tryParse(savedAtString);
        final now = DateTime.now();
        final difference = now.difference(savedAt!).inHours;
        print('[TokenCheck] diff: $difference');

        if (difference < 720) {
          setState(() => isTokenValid = true);
          return;
        }
      }

      setState(() => isTokenValid = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brand Online KZ',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        fontFamily: 'Gerbera',
      ),
      routes: {
        '/auth': (context) => const LoginScreen(),
      },
      home:
      isTokenValid == null
          ? const Scaffold(backgroundColor: AppColors.primaryBlue, body: Center(child: CircularProgressIndicator(
            color: Colors.white,
          )))
          : isTokenValid == true
          ? const RoadMap(selectedIndx: 0, state: 0)
          : const LoginScreen(),
    );
  }
}
