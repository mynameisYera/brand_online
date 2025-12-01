import 'package:flutter/material.dart';
import '../../../general/GeneralUtil.dart';
import '../../../general/MainEntryPage.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String _pageValidator = '';
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  final LoginScreenWidget widgets = LoginScreenWidget();

  @override
  void setState(VoidCallback fn) {
    _pageValidator = '';
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widgets.spaceBreaker(MediaQuery.of(context).size.height * 0.1),
                widgets.logoTitle(context),
                widgets.spaceBreaker(MediaQuery.of(context).size.height * 0.05),

                // Username
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: widgets.usernameField(_username, context, ''),
                ),
                const SizedBox(height: 20),

                // Password
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      TextField(
                        controller: _password,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          hintText: ' * * * * * * * * ',
                          prefixText: ' ',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: GeneralUtil.mainColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: GeneralUtil.mainColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: GeneralUtil.mainColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_pageValidator, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Forgot password
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Құпия сөзді ұмыттыңыз ба?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ЖАЛҒАСТЫРУ
                TextButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: GeneralUtil.getBlueButtonStyle(context),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.04 + 4,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "ЖАЛҒАСТЫРУ",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // АРТҚА
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainEntryPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "АРТҚА",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: GeneralUtil.mainColor,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_isLoading) {
      return;
    }

    if (_username.text.isEmpty || _password.text.isEmpty) {
      setState(() {
        _pageValidator = 'Пайдаланушы аты мен құпия сөзді енгізіңіз';
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
        _pageValidator = 'Жүйеге кіру мүмкін емес';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pageValidator = 'Қате орын алды. Кейінірек қайталап көріңіз.';
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