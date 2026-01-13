import 'dart:async';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/formatters/phone_number_formatter.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:brand_online/main.dart';
import '../authorization/service/auth_service.dart';
import '../authorization/ui/widget/LoginScreenWidget.dart';
import '../authorization/ui/widget/RegistrationWidget.dart';
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
        });
        return;
      }
      
      // Проверка кода через API
      String phone =
          _phoneNumberController.text.replaceAll(RegExp(r'[ ()-]'), '');
      phone = phone.replaceFirst("+7", "8");
      isLoading = true;
      
      String? response = '';
      AuthService()
          .verifyPhoneCode(phone, code!)
          .then((res) => {
                if (res != null && res.message == "Verification successful.")
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
            _page2Validator = response!.replaceAll('[', '').replaceAll(']', '');
          });
        },
      );
      return;
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
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _currentPage >= index
                            ? AppColors.primaryBlue
                            : AppColors.grey,
                      ),
                    );
                  }),
                ),
              ),
              AppButton(
                      onPressed: _nextPage,
                      text: _currentPage == 2 ? "АЯҚТАУ" : "ЖАЛҒАСТЫРУ",
                      isLoading: isLoading,
                    ),
              SizedBox(height: 10),
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
                child: Text("Қайту", style: TextStyles.bold(AppColors.primaryBlue, fontSize: 16), textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text(
              'Құпиясөзді қалпына келтіру',
              style: TextStyles.bold(AppColors.black, fontSize: 28),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 48),

          AppTextField(
            labelText: "Телефон нөмірі", 
            controller: _phoneNumberController, 
            hintText: "Телефон нөмірін енгізіңіз", 
            prefixIcon: Icons.phone_outlined, 
            keyboardType: TextInputType.phone, 
            maxLength: 17, 
            inputFormatters: [KazakhPhoneNumberFormatter()], 
            errorText: _page1Validator.isNotEmpty ? _page1Validator : null,
          ),
          
          // Center(
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width * 0.8,
          //     child: TextField(
          //       focusNode: _focusNode,
          //       controller: _phoneNumberController,
          //       keyboardType: TextInputType.phone,
          //       inputFormatters: [
          //         FilteringTextInputFormatter.allow(RegExp(r'[0-9,+]')),
          //         const NationalPhoneNumberTextInputFormatter(
          //           prefix: '+7',
          //           groups: [
          //             (length: 3, leading: ' (', trailing: ') '),
          //             (length: 3, leading: '', trailing: '-'),
          //             (length: 4, leading: '', trailing: ' '),
          //           ],
          //         ),
          //         LengthLimitingTextInputFormatter(17),
          //       ],
          //       decoration: widgets.getPhoneDecorationGreen(''),
          //     ),
          //   ),
          // ),
          Spacer(),
          Center(
            child: Text(
                  'Құпиясөзді қадпына келтіру үшін сіздің WhatsApp нөміріңізге верификация коды жіберіледі. ',
                  style: TextStyles.regular(AppColors.black),
                  textAlign: TextAlign.center,
                ),
          ),

          SizedBox(height: 250),
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
            child: Text("Растау кодын енгізіңіз", style: TextStyles.bold(AppColors.black, fontSize: 28), textAlign: TextAlign.center),
          ),
          SizedBox(height: 80),
          Text("Растау коды сіздің WhatsApp нөміріңізге жіберілді. Верификацияны аяқтау үшін төменге енгізіңіз", style: TextStyles.regular(AppColors.black), textAlign: TextAlign.center),
          SizedBox(height: 10),
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
                                  BorderSide(color: AppColors.primaryBlue)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: AppColors.primaryBlue, width: 1),
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
          SizedBox(height: 20),
          isButtonDisabled
              ? Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                      TextSpan(text: "Кодты қайта жіберу ", style: TextStyles.semibold(AppColors.black, fontSize: 13)),
                      TextSpan(text: formatTime(timerCountdown), style: TextStyles.semibold(AppColors.primaryBlue, fontSize: 13)),
                      ],
                    ),
                  ),
                ) 
              : Center(
                  child: TextButton(
                    onPressed: isButtonDisabled ? null : resendCode,
                    child: Text(
                      "Кодты қайта жіберу",
                      style: TextStyle(color: AppColors.primaryBlue),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Center(
            child: Text(
              'Құпиясөз енгізіңіз',
              style: TextStyles.bold(AppColors.black, fontSize: 28),
            ),
          ),
          SizedBox(height: 40),
          AppTextField(
            labelText: "Құпиясөз",
            controller: _password1,
            hintText: "Құпиясөзді енгізіңіз",
            prefixIcon: Icons.lock,
            obscureText: _obscureText,
          ),
          SizedBox(height: 20),
          AppTextField(
            labelText: "Құпиясөзді қайта енгізіңіз",
            controller: _password2,
            hintText: "Құпиясөзді енгізіңіз",
            prefixIcon: Icons.lock,
            obscureText: _obscureText2,
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
