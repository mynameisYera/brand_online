import 'package:brand_online/authorization/ui/screen/RegistrationScreen.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/formatters/phone_number_formatter.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../general/ResetPasswordScreen.dart';
import '../../../roadMap/ui/screen/RoadMap.dart';
import '../../service/auth_service.dart';
import '../widget/LoginScreenWidget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String _usernameError = '';
  String _passwordError = '';
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  final LoginScreenWidget widgets = LoginScreenWidget();
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    _usernameError = '';
    _passwordError = '';
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * 3.14159,
                      child: Container(
                        width: 180,
                        height: 180,
                        padding: EdgeInsets.all(50),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0082FF), Color(0xFF104CAA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Transform.rotate(
                          angle: -_rotationController.value * 2 * 3.14159,
                          child: SvgPicture.asset('assets/icons/logo_e.svg', width: 50, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SvgPicture.asset('assets/icons/slogan.svg', width: 300),
                const SizedBox(height: 30),
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
                    controller: _username,
                    errorText: _usernameError.isNotEmpty ? _usernameError : null,
                    onChanged: (value) {
                      if (_usernameError.isNotEmpty) {
                        setState(() {
                          _usernameError = '';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  child: AppTextField(
                    labelText: 'Құпия сөз',
                    hintText: 'Құпия сөзді енгізіңіз',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscureText,
                    keyboardType: TextInputType.visiblePassword,
                    controller: _password,
                    errorText: _passwordError.isNotEmpty ? _passwordError : null,
                    onChanged: (value) {
                      if (_passwordError.isNotEmpty) {
                        setState(() {
                          _passwordError = '';
                        });
                      }
                    },
                    onSubmitted: (value) {
                      _handleLogin();
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Құпия сөзді ұмыттыңыз ба?',
                        style: TextStyles.regular(AppColors.secondaryBlueText),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                        );
                      },
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),

                AppButton(
                  text: 'ЖАЛҒАСТЫРУ',
                  variant: AppButtonVariant.solid,
                  color: AppButtonColor.blue,
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Аккаунт жоқ па? ',
                      style: TextStyles.medium(AppColors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationPage()),
                        );
                      },
                      child: Text(
                        'Тіркелу',
                        style: TextStyles.medium(AppColors.primaryBlue),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
        ),
        )
      ),
    );
  }

  Future<void> _handleLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_isLoading) {
      return;
    }

    if (_username.text.isEmpty && _password.text.isEmpty) {
      setState(() {
        _usernameError = 'Телефон нөмірін енгізіңіз';
        _passwordError = 'Құпия сөзді енгізіңіз';
      });
      return;
    }
    
    if (_username.text.isEmpty) {
      setState(() {
        _usernameError = 'Телефон нөмірін енгізіңіз';
      });
      return;
    }
    
    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = 'Құпия сөзді енгізіңіз';
      });
      return;
    }

    String phone = _username.text.replaceAll(RegExp(r'[ ()-]'), '');
    phone = phone.replaceFirst("+7", "8");

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await AuthService().getToken(phone, _password.text);

      if (res != null) {
        await savePreferences(res.accessToken, res.refreshToken);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        navigateToMainPage(context);
        return;
      }

      if (!mounted) return;
      setState(() {
        _passwordError = 'Жүйеге кіру мүмкін емес';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _passwordError = 'Қате орын алды. Кейінірек қайталап көріңіз.';
        _isLoading = false;
      });
    }
  }


  Future<void> savePreferences(String accessToken, String refreshToken) async {
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
}