import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:phone_number_text_input_formatter/phone_number_text_input_formatter.dart';
import 'package:brand_online/main.dart';

import '../authorization/service/auth_service.dart';
import '../authorization/ui/widget/LoginScreenWidget.dart';
import '../authorization/ui/widget/RegistrationWidget.dart';
import 'GeneralUtil.dart';
import 'SplashScreenWithoutButtons.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  bool isLoading = false;
  final TextEditingController _username = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  late String _page1Validator = '';
  late String _page2Validator = '';
  late String _page3Validator = '';
  RegistrationWidget registrWidget = RegistrationWidget();

  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _focusNode.dispose();
    _username.dispose();
    _timer?.cancel();
    super.dispose();
  }

  double _scale = 1.0;

  void startAnimation() {
    setState(() {
      _scale = 1.1;
    });

    Future.delayed(Duration(milliseconds: 150), () {
      setState(() {
        _scale = 1.0;
      });
    });
  }

  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int timerCountdown = 120;
  bool isButtonDisabled = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void startTimer() {
    setState(() {
      timerCountdown = 120;
      isButtonDisabled = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timerCountdown > 0) {
            timerCountdown--;
          } else {
            timer.cancel();
            isButtonDisabled = false;
          }
        });
      }
    });
  }

  void resendCode() {
    startTimer();
    String phone =
        _phoneNumberController.text.replaceAll(RegExp(r'[ ()-]'), '');
    phone = phone.replaceFirst("+7", "8");
    String? response = '';
    AuthService()
        .forgotPassword(phone)
        .then((res) => {
              if (res != null && res.message == "Verification code sent.")
                {
                  response = '',
                  _pageController.animateToPage(
                    _currentPage + 1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  isLoading = false,
                }
              else
                {
                  response = res!.message,
                  isLoading = false,
                }
            })
        .then(
      (value) {
        setState(() {
          isLoading = false;
          _page1Validator = response!.replaceAll('[', '').replaceAll(']', '');
        });
      },
    );
  }

  void _nextPage() {
    startAnimation();
    if (_currentPage == 0) {
      setState(() {
        startTimer();
        _page1Validator = '';
        _page1Validator = registrWidget.checkPage2(_phoneNumberController)!;
      });
      if (_page1Validator == '') {
        isLoading = true;

        String phone =
            _phoneNumberController.text.replaceAll(RegExp(r'[ ()-]'), '');
        phone = phone.replaceFirst("+7", "8");
        String? response = '';
        AuthService()
            .forgotPassword(phone)
            .then((res) => {
                  if (res != null && res.message == "Verification code sent.")
                    {
                      response = '',
                      _pageController.animateToPage(
                        _currentPage + 1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      isLoading = false,
                    }
                  else
                    {
                      response = res!.message,
                      isLoading = false,
                    }
                })
            .then(
          (value) {
            setState(() {
              isLoading = false;
              _page1Validator =
                  response!.replaceAll('[', '').replaceAll(']', '');
            });
          },
        );
      }
    }

    if (_currentPage == 1) {
      setState(() {
        _page2Validator = '';
      });
      String? code = '';
      if (controllers.isNotEmpty) {
        for (var element in controllers) {
          code = element.text + code!;
        }
        code = code?.split('').reversed.join('');
      }
      if (code != null && code.length < 6) {
        setState(() {
          _page2Validator = 'Арнаны толтырыныз';
          return;
        });
      } else {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
    if (_currentPage == 2) {

      final pwd1 = _password1.text.trim();
      final pwd2 = _password2.text.trim();


      setState(() => _page3Validator = '');

      if (pwd1.length < 8) {
        setState(() {
          _page3Validator = 'Құпия сөз кемінде 8 таңбадан тұруы керек';
        });
        return;
      }

      if (pwd1 != pwd2) {
        setState(() {
          _page3Validator = 'Құпия сөздер сәйкес келмейді';
        });
        return;
      }

      String phone =
      _phoneNumberController.text.replaceAll(RegExp(r'[ ()-]'), '');
      phone = phone.replaceFirst("+7", "8");

      String? code = '';
      if (controllers.isNotEmpty) {
        for (var element in controllers) {
          code = element.text + code!;
        }
        code = code?.split('').reversed.join('');
      }

      // ignore: unused_local_variable
      String? response = '';

      AuthService()
          .passwordReset(phone, code!, pwd1)
          .then((res) async {
        if (res != null && res.access != null) {
          if (res.refresh != null) {
            await storage.write(key: 'auth_token', value: res.access!);
            await storage.write(key: 'auth_saved_at', value: DateTime.now().toIso8601String());
          }

          response = '';
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SplashScreenWithoutButtons()),
                (route) => false,
          );

          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((e) {
        setState(() {
          isLoading = false;
          _page3Validator = 'Ошибка: $e';
        });
      });
    }

  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _currentPage >= index
                            ? GeneralUtil.greenColor
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 1.0, end: _scale),
                duration: Duration(milliseconds: 150),
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: TextButton(
                      onPressed: _nextPage,
                      style: GeneralUtil.getGreenButtonStyle(context),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentPage == 2 ? "АЯҚТАУ" : "ЖАЛҒАСТЫРУ",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  _currentPage > 0
                      ? _previousPage()
                      : (
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Application(),
                            ),
                            (Route<dynamic> route) => false,
                          ),
                        );
                },
                style: GeneralUtil.getWhiteButtonStyle(context),
                child: Text(
                  "АРТҚА",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: GeneralUtil.greenColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/logo3.png',
                color: GeneralUtil.greenColor,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Step 2:
                  _buildStep1(),
                  // Step 3:
                  _buildStep2(),
                  // Step 6:
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LoginScreenWidget widgets = LoginScreenWidget();

  // Step 2: Email Information
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.1),
          Center(
            child: Text(
              'Құпия сөзді қалпына келтіру',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Телефон нөміріңіз',
              style: TextStyle(
                fontSize: 14,
                color: GeneralUtil.greyColor,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                focusNode: _focusNode,
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,+]')),
                  const NationalPhoneNumberTextInputFormatter(
                    prefix: '+7',
                    groups: [
                      (length: 3, leading: ' (', trailing: ') '),
                      (length: 3, leading: '', trailing: '-'),
                      (length: 4, leading: '', trailing: ' '),
                    ],
                  ),
                  LengthLimitingTextInputFormatter(17),
                ],
                decoration: widgets.getPhoneDecorationGreen(''),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Center(
                child: Text(
                  'Сіздің Whats`App нөміріңізге растау кодың жібереміз',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: Text(
                  _page1Validator,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Step 3: Password Information
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.1),
          Center(
              child: Text(
            textAlign: TextAlign.center,
            'Растау коды сіздің Whats` App нөміріңізге жіберілді.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto', // Add Roboto font family here
              fontWeight: FontWeight.bold,
            ),
          )),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: SizedBox(
                      width: 50,
                      height: 69,
                      child: TextField(
                        controller: controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black, 
                        ),
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  BorderSide(color: GeneralUtil.mainColor)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            // Rounded corners
                            borderSide: BorderSide(
                                color: GeneralUtil.greenColor,
                                width: 2), // Blue color when focused
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            // Rounded corners
                            borderSide: BorderSide(
                                color: GeneralUtil.greenColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          // Automatically move to next field when a digit is entered
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                          // Optionally, add logic to move focus backward when deleting.
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 20),
          isButtonDisabled
              ? Center(
                  child: Text(
                    isButtonDisabled
                        ? "Кодты қайта жіберу  ${formatTime(timerCountdown)} сек."
                        : "",
                  ),
                )
              : Center(
                  child: TextButton(
                    onPressed: isButtonDisabled ? null : resendCode,
                    child: Text(
                      "Кодты қайта жіберу",
                      style: TextStyle(color: GeneralUtil.mainColor),
                    ),
                  ),
                ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: Text(
                  _page2Validator,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _obscureText = true;
  bool _obscureText2 = true;

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.1),
          Center(
            child: Text(
              'Құпия сөз',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Жаңа құпия сөз еңгізіңіз',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                obscureText: _obscureText,
                controller: _password1,
                decoration: InputDecoration(
                  prefixText: ' ',
                  hintText: ' * * * * * * * * ',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      // Toggle eye icon
                      color: GeneralUtil.greenColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle the obscureText value
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: GeneralUtil.greenColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.greenColor,
                        width: 2), // Blue color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.greenColor,
                        width: 2), // Blue color when enabled
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 30),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Жаңа құпия сөз еңгізіңіз',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                obscureText: _obscureText2,
                controller: _password2,
                decoration: InputDecoration(
                  prefixText: ' ',
                  hintText: ' * * * * * * * * ',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText2 ? Icons.visibility : Icons.visibility_off,
                      // Toggle eye icon
                      color: GeneralUtil.greenColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText2 =
                            !_obscureText2; // Toggle the obscureText value
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: GeneralUtil.greenColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.greenColor,
                        width: 2), // Blue color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.greenColor,
                        width: 2), // Blue color when enabled
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 30),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: Text(
                  _page3Validator,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
