import'dart:async';

import 'package:brand_online/authorization/ui/screen/LoginScreen.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/formatters/phone_number_formatter.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import '../../../general/GeneralUtil.dart';
import '../../../roadMap/ui/screen/RoadMap.dart';
import '../../entity/SignEntity.dart';
import '../../service/auth_service.dart';
import '../widget/LoginScreenWidget.dart';
import '../widget/RegistrationWidget.dart';
import '../widget/dropdown_widget.dart';

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
    if (_currentPage == 0) {
      setState(() {
        _page1Validator = '';
        _page2Validator = '';
      });
      _page1Validator = registrWidget.checkPage1(_firstname, _lastname)!;
      if (_page1Validator != '') return;
      
      _page2Validator = registrWidget.checkPage2(_phoneNumberController)!;
      if (_page2Validator != '') return;
      
      setState(() {
        isLoading = true;
        startTimer();
      });
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
      return;
    }

    if (_currentPage == 1) {
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
      return;
    }
    
    if (_currentPage == 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (_currentPage == 3) {
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
            selectedKey == '1' ? 'parent' : 'student',
            );
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
  }

  int userType = 0;

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
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: _currentPage >= index ? AppColors.primaryBlue : AppColors.grey,
                    ),
                  );
                }),
              ),
            ),
            if (_currentPage == 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Батырма басу арқылы сіз дербес деректерді жинауға және өңдеуге келісім бересіз", 
                  style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Manrope', fontFamilyFallback: ['Roboto'], fontWeight: FontWeight.w400
                ), textAlign: TextAlign.center,),
              ),

              SizedBox(height: 20),

            AppButton(
              text: _currentPage == 3 ? "АЯҚТАУ" : "ЖАЛҒАСТЫРУ", 
              onPressed: _nextPage, isLoading: isLoading
            ),
            
            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                _currentPage > 0
                    ? _previousPage()
                    : Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                          (Route<dynamic> route) => false,
                    );
              },
              child: Text(
                "Қайту",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: AppColors.primaryBlue,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Manrope',
                  fontFamilyFallback: ['Roboto'],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Step 1:
                  _buildStep1(),
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
      )
    ),
    );
  }

  // Step 1: Personal Information (Name, Phone)
  Widget _buildStep1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text("Регистрация", 
              style: TextStyles.bold(AppColors.black, fontSize: 28)),
          ),
          SizedBox(height: 48),
          AppTextField(labelText: "Аты", controller: _firstname, hintText: "Аты", prefixIcon: Icons.person_outline),
          SizedBox(height: 20),
          AppTextField(labelText: "Тегі", controller: _lastname, hintText: "Тегі", prefixIcon: Icons.person_outline),
          SizedBox(height: 20),
          SizedBox(
            child: AppTextField(
              labelText: 'Телефон нөмірі',
              hintText: 'Телефон нөмірін енгізіңіз',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 17,
              inputFormatters: [
                KazakhPhoneNumberFormatter()
              ],
              controller: _phoneNumberController,
              errorText: _page2Validator.isNotEmpty ? _page2Validator : null,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _page1Validator,
                style: TextStyles.regular(AppColors.errorRed),
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

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text("Растау кодын енгізіңіз", 
              style: TextStyles.bold(AppColors.black, fontSize: 28)),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.3),
          Center(
              child: Text(
            textAlign: TextAlign.center,
            'Растау коды сіздің WhatsApp нөміріңізге жіберілді. Верификацияны аяқтау үшін төменге енгізіңіз',
            style: TextStyles.regular(Colors.black),
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
                      width: 48,
                      height: 60,
                      child: TextField(
                        controller: controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyles.bold(AppColors.black, fontSize: 24),
                        maxLength: 1,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          counterText: '',
                          fillColor: AppColors.primaryBlue,
                          hoverColor: AppColors.primaryBlue,
                          focusColor: AppColors.primaryBlue,
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  BorderSide(color: GeneralUtil.mainColor)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: GeneralUtil.mainColor, width: 1),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
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
          SizedBox(height: 10),
          isButtonDisabled
              ? Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Кодты қайта жіберу ", style: TextStyles.semibold(AppColors.black, fontSize: 13)),
                        TextSpan(text: formatTime(timerCountdown), style: TextStyles.semibold(AppColors.primaryBlue)),
                      ],
                    ),
                  ),
                )
              : Center(child: TextButton(
            onPressed: isButtonDisabled ? null : resendCode,
            child: Text(
              "Кодты қайта жіберу",
              style: TextStyles.semibold(AppColors.primaryBlue, fontSize: 13),
            ),
          ),),
          SizedBox(height: 5),
          Center(
            child: Text(
              _page3Validator,
              style: TextStyles.regular(AppColors.errorRed),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  

  String selectedKey = '1';

  final Map<String, String> dropdownMap = {
    '1': 'Ата ана',
    '2': 'Оқушы',
  };

  Widget _buildStep5() {
    return Visibility(
      visible: userType == 2 ? false : true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Center(
              child: Text("Рольіңізді таңдаңыз", 
                style: TextStyles.bold(AppColors.black, fontSize: 28)),
            ),
            SizedBox(height: 20),
            Center(
              child: Text("Сіз қай рольдесіз?", style: TextStyles.bold(AppColors.black, fontSize: 13),),
            ),
            SizedBox(height: 60,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: AppDropdown<String>(
                labelText: 'Роль',
                hintText: 'Роль',
                prefixIcon: null,
                value: selectedKey,
                onChanged: (String? newKey) {
                  setState(() {
                    selectedKey = newKey!;
                  });
                },
                items: dropdownMap.entries
                    .map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/synyp.svg",
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(width: 8),
                        Text(
                          entry.value,
                          style: TextStyles.medium(AppColors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                color: Color(0xffC5E5FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text("💡Кейінірек профильде сыныпты өзгертуге болады", 
                style: TextStyles.regular(Color(0xffA3A3A3)), textAlign: TextAlign.center,),
              ),
            ),
            SizedBox(height: 210),
          ],
        ),
      ),
    );
  }

  bool _obscureText = true;
  bool _obscureText2 = true;

  Widget _buildStep6() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text("Құпиясөз енгізіңіз", style: TextStyles.bold(AppColors.black, fontSize: 28),),
          ),
          SizedBox(height: 60),
          AppTextField(labelText: "Құпиясөз", controller: _password1, hintText: "Құпия сөз", prefixIcon: Icons.lock, obscureText: _obscureText,),
          SizedBox(height: 20),
          AppTextField(labelText: "Құпиясөзді қайта енгізіңіз", controller: _password2, hintText: "Құпия сөз", prefixIcon: Icons.lock, obscureText: _obscureText2,),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: Text(
                  _page5Validator,
                  style: TextStyle(color: Colors.red, fontFamily: 'Manrope', fontFamilyFallback: ['Roboto'], fontWeight: FontWeight.w400),
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
                height: 69,
                child: TextField(
                  controller: controllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: GeneralUtil.mainColor)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: GeneralUtil.mainColor,
                          width: 2), // Blue color when focused
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: GeneralUtil.mainColor, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      FocusScope.of(context).nextFocus();
                    }
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
