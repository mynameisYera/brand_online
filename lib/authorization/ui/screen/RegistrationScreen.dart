import'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number_text_input_formatter/phone_number_text_input_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../general/GeneralUtil.dart';
import '../../../general/MainEntryPage.dart';
import '../../../roadMap/ui/screen/RoadMap.dart';
import '../../entity/SignEntity.dart';
import '../../service/auth_service.dart';
import '../widget/LoginScreenWidget.dart';
import '../widget/RegistrationWidget.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  bool isLoading = false;
  final TextEditingController _username = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  late String _page1Validator = '';
  late String _page2Validator = '';
  late String _page3Validator = '';
  late String _page5Validator = '';
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

  double _scale = 1.0; // Начальный размер

  void startAnimation() {
    setState(() {
      _scale = 1.1; // Увеличиваем размер
    });

    Future.delayed(Duration(milliseconds: 150), () {
      setState(() {
        _scale = 1.0; // Возвращаем обратно
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
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}"; // Формат 2:00, 1:59 и т.д.
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
        .getVerificationCode(phone)
        .then((res) => {
      if (res != null && res.message == "Verification code sent.")
        {
          response = '',
        }
      else
        {
          response = res!.message,
          _page2Validator =
              response!.replaceAll('[', '').replaceAll(']', ''),
        }
    })
        .then(
          (value) {
        setState(() {
          _page2Validator =
              response!.replaceAll('[', '').replaceAll(']', '');
        });
      },
    );
  }

  void _nextPage() {
    startAnimation();
    if (_currentPage == 0) {
      setState(() {
        _page1Validator = '';
      });
      setState(() {
        _page1Validator = registrWidget.checkPage1(_firstname, _lastname)!;
      });
      if (_page1Validator != '') return;
    }
    if (_currentPage == 1) {
      setState(() {
        isLoading = true;
        startTimer();
        _page2Validator = '';
        _page2Validator = registrWidget.checkPage2(_phoneNumberController)!;
      });
      if (_page2Validator != '') {
        return;
      } else {
        String phone =
            _phoneNumberController.text.replaceAll(RegExp(r'[ ()-]'), '');
        phone = phone.replaceFirst("+7", "8");
        String? response = '';
        AuthService()
            .getVerificationCode(phone)
            .then((res) => {
                  if (res != null && res.message == "Verification code sent.")
                    {
                      isLoading = false,
                      response = '',
                      _pageController.animateToPage(
                        _currentPage + 1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    }
                  else
                    {
                      isLoading = false,
                      response = res!.message,
                      _page2Validator =
                          response!.replaceAll('[', '').replaceAll(']', ''),
                    }
                })
            .then(
          (value) {
            setState(() {
              _page2Validator =
                  response!.replaceAll('[', '').replaceAll(']', '');
            });
          },
        );
      }
    }

    if (_currentPage == 2) {
      setState(() {
        _page3Validator = '';
      });

      String? response = '';
      String? code = '';
      if (controllers.isNotEmpty) {
        for (var element in controllers) {
          code = element.text + code!;
        }
        code = code?.split('').reversed.join('');
      }
      String phone =
          _phoneNumberController.text.replaceAll(RegExp(r'[ ()-]'), '');
      phone = phone.replaceFirst("+7", "8");
      isLoading = true;
      AuthService()
          .verifyPhoneCode(phone, code!)
          .then((res) => {
                if (res != null && res.message == "Verification successful.")
                  {
                    isLoading = false,
                    response = '',
                    _pageController.animateToPage(
                      _currentPage + 1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
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
            _page3Validator = response!.replaceAll('[', '').replaceAll(']', '');
          });
        },
      );
    }
    if (_currentPage == 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (_currentPage == 4) {
      setState(() {
        _page5Validator = '';
      });
      final RegExp passwordRegExp = RegExp(r'^.{8,20}$');

      String? validatePassword(String? value) {
        if (value == null || value.isEmpty) {
          return 'Құпия сөзіңізді енгізіңіз';
        }
        if (!passwordRegExp.hasMatch(value)) {
          return 'Құпия сөз 8-20 таңбадан тұруы керек';
        }
        if (_password1.text != _password2.text) {
          return 'Құпия сөз сәйкес болуы керек';
        }
        return '';
      }

      _page5Validator = validatePassword(_password1.text)!;
      _page5Validator = validatePassword(_password2.text)!;
      if (_page5Validator == '') {
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
        SignEntity entity = SignEntity(
            phone,
            code!,
            _firstname.text,
            _lastname.text,
            _password1.text,
            'student',
            selectedKey);
        String? response = '';
        isLoading = true;
        AuthService()
            .verifyAndSign(entity)
            .then((res) => {
                  if (res != null &&
                      res.message == 'User created successfully.')
                    {
                      isLoading = false,
                      response = '',
                      _handleLogin(phone, _password1.text),
                    }
                  else
                    {
                      isLoading = false,
                      response = res?.message,
                    }
                })
            .then(
          (value) {
            setState(() {
              _page5Validator = response!;
              isLoading = false;
            });
          },
        );
      }
    }
    if (_currentPage < 5 &&
        _currentPage != 1 &&
        _currentPage != 2 &&
        _currentPage != 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int userType = 0;

  void _previousPage() {
    if (_currentPage == 4) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (_currentPage > 0 && _currentPage != 5) {
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

  void _handleLogin(String phoneNumber, String password) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (phoneNumber.isNotEmpty && password.isNotEmpty) {
      String phone = phoneNumber.replaceAll(RegExp(r'[ ()-]'), '');
      phone = phone.replaceFirst("+7", "8");

      AuthService().getToken(phone, password).then((res) {
        if (res != null) {
          savePreferences(res.accessToken, res.refreshToken);
          navigateToMainPage(context);
        }
      });
    }
  }

  void savePreferences(String accessToken, String refreshToken) async {
    await _storage.write(key: 'auth_token', value: accessToken);
    await _storage.write(key: 'auth_saved_at', value: DateTime.now().toIso8601String());
  }

  void navigateToMainPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => RoadMap(selectedIndx: 0, state: 0,)),
          (Route<dynamic> route) => false,
    );
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
            // 🔽 Добавляем согласие ПЕРЕД кнопками
            if (_currentPage == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'Батырма басу арқылы сіз '),
                      TextSpan(
                        text:
                        'дербес деректерді жинауға',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(
                                'https://www.restartonline.kz/privacy-policy'));
                          },
                      ),
                      TextSpan(text: ' жане'),
                      TextSpan(
                        text:
                        ' пайдаланушы келісімімен',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(
                                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                          },
                      ),
                      TextSpan(text: ' келісесіз'),
                    ],
                  ),
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
                    style: GeneralUtil.getBlueButtonStyle(context),
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
                      _currentPage == 5 ? "АЯҚТАУ" : "ЖАЛҒАСТЫРУ",
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
            TextButton(
              onPressed: () {
                _currentPage > 0
                    ? _previousPage()
                    : Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainEntryPage(),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              style: GeneralUtil.getWhiteButtonStyle(context),
              child: Text(
                "АРТҚА",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: GeneralUtil.mainColor,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: _currentPage >= index ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // Step 1:
                _buildStep1(),
                // Step 2:
                _buildStep2(),
                // Step 3:
                _buildStep3(),
                // Step 5:
                _buildStep5(),
                // Step 6:
                _buildStep6(),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  // Step 1: Personal Information (Name, Phone)
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.3),
          Center(
            child: Text(
              'Есіміңізді енгізіңіз',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 5),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: _firstname,
                decoration: GeneralUtil.getTextFieldDecoration("Есім"),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Тегіңізді енгізіңіз',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 5),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: _lastname,
                decoration: GeneralUtil.getTextFieldDecoration("Тегі"),
              ),
            ),
          ),
          SizedBox(height: 20),

          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _page1Validator,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  LoginScreenWidget widgets = LoginScreenWidget();

  // Step 2: Email Information
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.4),
          Center(
            child: Text(
              'Телефон нөміріңізді енгізіңіз',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
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
                decoration: widgets.getPhoneDecoration(''),
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

  // Step 3: Password Information
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.3),
          Center(
              child: Text(
            textAlign: TextAlign.center,
            ' Растау коды сіздің Whats` App нөміріңізге жіберілді. Верификацияны аяқтау үшін төменге енгізіңіз',
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
                  // ... existing code ...
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
// ... existing code ...
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            // Rounded corners
                            borderSide: BorderSide(
                                color: GeneralUtil.mainColor, width: 2),
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
              : Center(child: TextButton(
            onPressed: isButtonDisabled ? null : resendCode,
            child: Text(
              "Кодты қайта жіберу",
              style: TextStyle(color: GeneralUtil.mainColor),
            ),
          ),),
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

  // Widget _buildStep4() {
  //   return Padding(
  //     padding: const EdgeInsets.all(1.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(height: MediaQuery.of(context).size.width * 0.3),
  //         Center(
  //           child: Text(
  //             'Рөліңізді таңдаңыз',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 20),
  //         Center(
  //           child: TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 userType = 1;
  //               });
  //             },
  //             style: (userType == 1)
  //                 ? GeneralUtil.getBlueButtonStyle(context)
  //                 : GeneralUtil.getWhiteButtonBorderStyle(context),
  //             child: Text(
  //               "Оқушы",
  //               style: TextStyle(
  //                 fontSize: MediaQuery.of(context).size.width * 0.04,
  //                 fontWeight: FontWeight.bold,
  //                 color: (userType == 1) ? Colors.white : Colors.black,
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 20),
  //         Center(
  //           child: TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 userType = 2;
  //               });
  //             },
  //             style: (userType == 2)
  //                 ? GeneralUtil.getBlueButtonStyle(context)
  //                 : GeneralUtil.getWhiteButtonBorderStyle(context),
  //             child: Text(
  //               "Ата-ана",
  //               style: TextStyle(
  //                 fontSize: MediaQuery.of(context).size.width * 0.04,
  //                 fontWeight: FontWeight.bold,
  //                 color: (userType == 2) ? Colors.white : Colors.black,
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 20),
  //         Center(
  //           child: SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.8,
  //             child: Center(
  //               child: Text(
  //                 _page4Validator,
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String selectedKey = '1';

  final Map<String, String> dropdownMap = {
    '1': '1 сынып',
    '2': '2 сынып',
    '3': '3 сынып',
    '4': '4 сынып',
    '5': '5 сынып',
    '6': '6 сынып',
    '7': '7 сынып',
    '8': '8 сынып',
    '9': '9 сынып',
  };

  Widget _buildStep5() {
    return Visibility(
      visible: userType == 2 ? false : true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.width * 0.3),
            Center(
              child: Text(
                'Сыныбыңызды таңдаңыз',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: GeneralUtil.mainColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: selectedKey,
                  onChanged: (String? newKey) {
                    setState(() {
                      selectedKey = newKey!;
                    });
                  },
                  items: dropdownMap.entries
                      .map<DropdownMenuItem<String>>((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key, // Store the key instead of the value
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.value, // Display the value in the dropdown
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                      color: Colors.blue.shade800),
                  isExpanded: true,
                  underline: SizedBox(),
                  hint: Text(
                    '   -  -  -  -  -  -  -  -  -  -  -  -  -  ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  menuMaxHeight: 200,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _obscureText = true;
  bool _obscureText2 = true;

  Widget _buildStep6() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.3),
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
                      color: Colors.blue,
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
                      borderSide: BorderSide(color: GeneralUtil.mainColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.mainColor,
                        width: 2), // Blue color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.mainColor,
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
                      color: Colors.blue,
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
                      borderSide: BorderSide(color: GeneralUtil.mainColor)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.mainColor,
                        width: 2), // Blue color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    borderSide: BorderSide(
                        color: GeneralUtil.mainColor,
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
                  _page5Validator,
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

class CodeVerification extends StatefulWidget {
  @override
  _CodeVerificationState createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {
  // Create 6 TextEditingControllers for each TextField
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: SizedBox(
                width: 43,
                height: 69, // Width of each TextField
                child: TextField(
                  controller: controllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                  // Center text inside the TextField
                  maxLength: 1,
                  // Limit input to 1 character
                  decoration: InputDecoration(
                    counterText: '', // Remove the counter text (e.g., "1/1")
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: GeneralUtil.mainColor)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      // Rounded corners
                      borderSide: BorderSide(
                          color: GeneralUtil.mainColor,
                          width: 2), // Blue color when focused
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      // Rounded corners
                      borderSide:
                          BorderSide(color: GeneralUtil.mainColor, width: 2),
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
    );
  }
}
