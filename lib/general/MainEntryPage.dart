import 'package:flutter/material.dart';
import 'dart:async';

import '../authorization/ui/screen/LoginScreen.dart';
import '../authorization/ui/screen/RegistrationScreen.dart';
import '../roadMap/ui/screen/RoadMap.dart';
import 'GeneralUtil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainEntryPage extends StatefulWidget {
  const MainEntryPage({super.key});

  @override
  _MainEntryPageState createState() => _MainEntryPageState();
}

class _MainEntryPageState extends State<MainEntryPage>
    with TickerProviderStateMixin {
  late AnimationController _controllerCloudLeft;
  late AnimationController _controllerCloudRight;
  late AnimationController _controllerLogo;
  late AnimationController _controllerTitle;
  late AnimationController _controllerButton;
  late Animation<double> _animationCloudLeft;
  late Animation<double> _animationCloudRight;
  late Animation<double> _animationLogo;
  late Animation<double> _animationTitle;
  late Animation<double> _animationButton;
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  @override
  void initState() {
    super.initState();

    // Animation controllers for the cloud images
    _controllerCloudLeft = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _controllerCloudRight = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _controllerLogo = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _controllerTitle = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _controllerButton = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Define animation for the left cloud (from bottom left)
    _animationCloudLeft = Tween<double>(begin: -200.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerCloudLeft, curve: Curves.easeInOut),
    );
    _animationLogo = Tween<double>(begin: 300.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerLogo, curve: Curves.fastOutSlowIn),
    );

    _animationTitle = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerTitle, curve: Curves.fastOutSlowIn),
    );

    _animationButton = Tween<double>(begin: -200.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerButton, curve: Curves.easeIn),
    );

    // Define animation for the right cloud (from right middle)
    _animationCloudRight = Tween<double>(begin: -300.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerCloudRight, curve: Curves.linear),
    );

    // Start both animations

    Future.delayed(const Duration(milliseconds: 500)).then((val) {
      _controllerLogo.forward();
      Future.delayed(const Duration(milliseconds: 500)).then((val) {
        _controllerCloudLeft.forward();
        _controllerCloudRight.forward();
        _controllerButton.forward();
        Future.delayed(const Duration(milliseconds: 500)).then((val) {
          _controllerTitle.forward();
        });
      });
    });
  }

  Future<void> checkToken() async {
    final savedAtString = await _storage.read(key: 'auth_saved_at');
    if (savedAtString == null) return;

    final savedAt = DateTime.tryParse(savedAtString);
    final now = DateTime.now();
    final difference = now.difference(savedAt!).inHours;

    final token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty && difference < 24) {
      navigateToMainPage(context);
    }
  }


  void navigateToMainPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RoadMap(selectedIndx: 0,state: 0,),
      ),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _controllerCloudLeft.dispose();
    _controllerCloudRight.dispose();
    _controllerLogo.dispose();
    _controllerTitle.dispose();
    _controllerButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 130, 255, 1),
      body: Stack(
        children: [
          // Cloud coming from bottom left
          AnimatedBuilder(
            animation: _animationCloudLeft,
            builder: (context, child) {
              return Positioned(
                left: _animationCloudLeft.value,
                bottom: 0,
                child: child!,
              );
            },
            child: Image.asset(
              'assets/images/clouds.png',
              width: 200,
              alignment: Alignment.bottomLeft,
            ),
          ),

          // Cloud coming from right middle
          AnimatedBuilder(
            animation: _animationCloudRight,
            builder: (context, child) {
              return Positioned(
                right: _animationCloudRight.value,
                top: 0,
                child: child!,
              );
            },
            child: Image.asset(
              'assets/images/clouds2.png',
              width: 200,
              alignment: Alignment.topRight,
            ),
          ),

          AnimatedBuilder(
            animation: _animationLogo,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: _animationLogo.value,
                bottom: 350,
                child: child!,
              );
            },
            child: Image.asset(
              'assets/images/splash_logo.png',
            ),
          ),

          AnimatedBuilder(
            animation: _animationTitle,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: _controllerTitle.value,
                bottom: 0,
                child:  Opacity(
                  opacity: _controllerTitle.value,
                  child: Align(
                    alignment: Alignment.center,
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset(
              'assets/images/splash_text.png',
              width: 300,
            ),
          ),
          AnimatedBuilder(
            animation: _animationButton,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _animationButton.value + 50,
                child: child!,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage()),
                    );
                  },
                  style: GeneralUtil.getWhiteButtonStyle(context),
                  child: Text(
                    "БАСТАУ",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto', // Add Roboto font family here
                      fontWeight: FontWeight.bold,
                      color: GeneralUtil.mainColor,
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space between buttons
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    // Text color
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "МЕНДЕ АККАУНТ БАР",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto', // Add Roboto font family here
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
