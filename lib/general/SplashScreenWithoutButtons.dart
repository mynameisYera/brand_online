// import 'package:flutter/material.dart';
// import 'dart:async';

// import '../roadMap/ui/screen/RoadMap.dart';

// class SplashScreenWithoutButtons extends StatefulWidget {
//   const SplashScreenWithoutButtons({super.key});

//   @override
//   _SplashScreenWithoutButtonsState createState() => _SplashScreenWithoutButtonsState();
// }

// class _SplashScreenWithoutButtonsState extends State<SplashScreenWithoutButtons>
//     with TickerProviderStateMixin {
//   late AnimationController _controllerCloudLeft;
//   late AnimationController _controllerCloudRight;
//   late AnimationController _controllerLogo;
//   late AnimationController _controllerTitle;
//   late AnimationController _controllerButton;
//   late Animation<double> _animationCloudLeft;
//   late Animation<double> _animationCloudRight;
//   late Animation<double> _animationLogo;
//   late Animation<double> _animationTitle;


//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const RoadMap(selectedIndx: 0, state: 0)),
//         );
//     });
//     // Animation controllers for the cloud images
//     _controllerCloudLeft = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//     _controllerCloudRight = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//     _controllerLogo = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//     _controllerTitle = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//     _controllerButton = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );

//     // Define animation for the left cloud (from bottom left)
//     _animationCloudLeft = Tween<double>(begin: -200.0, end: 0.0).animate(
//       CurvedAnimation(parent: _controllerCloudLeft, curve: Curves.easeInOut),
//     );
//     _animationLogo = Tween<double>(begin: 300.0, end: 0.0).animate(
//       CurvedAnimation(parent: _controllerLogo, curve: Curves.fastOutSlowIn),
//     );

//     _animationTitle = Tween<double>(begin: 0.0, end: 0.0).animate(
//       CurvedAnimation(parent: _controllerTitle, curve: Curves.fastOutSlowIn),
//     );

//     // Define animation for the right cloud (from right middle)
//     _animationCloudRight = Tween<double>(begin: -100.0, end: 0.0).animate(
//       CurvedAnimation(parent: _controllerCloudRight, curve: Curves.linear),
//     );

//     // Start both animations

//     Future.delayed(const Duration(milliseconds: 500)).then((val) {
//       _controllerLogo.forward();
//       Future.delayed(const Duration(milliseconds: 500)).then((val) {
//         _controllerCloudLeft.forward();
//         _controllerCloudRight.forward();
//         _controllerButton.forward();
//         Future.delayed(const Duration(milliseconds: 500)).then((val) {
//           _controllerTitle.forward();
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controllerCloudLeft.dispose();
//     _controllerCloudRight.dispose();
//     _controllerLogo.dispose();
//     _controllerTitle.dispose();
//     _controllerButton.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromRGBO(0, 130, 255, 1),
//       body: Stack(
//         children: [
//           // Cloud coming from bottom left
//           AnimatedBuilder(
//             animation: _animationCloudLeft,
//             builder: (context, child) {
//               return Positioned(
//                 left: _animationCloudLeft.value,
//                 bottom: 0,
//                 child: child!,
//               );
//             },
//             child: Image.asset(
//               'assets/images/clouds.png',
//               width: 200,
//               alignment: Alignment.bottomLeft,
//             ),
//           ),

//           // Cloud coming from right middle
//           AnimatedBuilder(
//             animation: _animationCloudRight,
//             builder: (context, child) {
//               return Positioned(
//                 right: _animationCloudRight.value,
//                 top: 0,
//                 child: child!,
//               );
//             },
//             child: Image.asset(
//               'assets/images/clouds2.png',
//               width: 200,
//               alignment: Alignment.topRight,
//             ),
//           ),

//           AnimatedBuilder(
//             animation: _animationLogo,
//             builder: (context, child) {
//               return Positioned(
//                 left: 0,
//                 right: 0,
//                 top: _animationLogo.value,
//                 bottom: 300,
//                 child: child!,
//               );
//             },
//             child: Image.asset(
//               'assets/images/splash_logo.png',
//             ),
//           ),

//           AnimatedBuilder(
//             animation: _animationTitle,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _controllerTitle.value,
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: child,
//                 ),
//               );
//             },
//             child: Image.asset(
//               'assets/images/splash_text.png',
//               width: 300,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
