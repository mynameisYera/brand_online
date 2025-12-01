import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number_text_input_formatter/phone_number_text_input_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../general/GeneralUtil.dart';
import '../../../roadMap/ui/screen/RoadMap.dart';
import '../../service/auth_service.dart';

class LoginScreenWidget {
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // SpaceBreaker
  Widget spaceBreaker(double breakerHeight) {
    return Container(
      height: breakerHeight,
    );
  }

  // logoTitle
  Widget logoTitle(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        width: 150,
        color: Color.fromRGBO(0, 130, 255, 1),
      ),
    );
  }

  // phoneNumber
  Widget phoneField(TextEditingController _phoneNumber, BuildContext context) {
    return TextField(
      controller: _phoneNumber,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.phone),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Номер телефона',
        hintStyle: TextStyle(color: Colors.grey),
        prefixText: ' ',
        suffixStyle: const TextStyle(
            color: Colors.green, decorationStyle: TextDecorationStyle.dotted),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.02,
        decoration: TextDecoration.none,
        letterSpacing: 1.0,
      ),
    );
  }

  // usernameField
  Widget usernameField(
      TextEditingController _username, BuildContext context, String label) {
    return TextField(
      keyboardType: TextInputType.phone,
      controller: _username,
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
      decoration: InputDecoration(
        labelText: label != '' ? label : null,
        hintText: '+7(___)___-____',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 30),
      ),
    );
  }

  InputDecoration getPhoneDecoration(String label) {
    return InputDecoration(
      labelText: label != '' ? label : null,
      hintText: '+7(___)___-____',
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: GeneralUtil.mainColor)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        borderSide: BorderSide(
            color: GeneralUtil.mainColor, width: 2), // Blue color when focused
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        borderSide: BorderSide(
            color: GeneralUtil.mainColor, width: 2), // Blue color when enabled
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 30),
    );
  }

  InputDecoration getPhoneDecorationGreen(String label) {
    return InputDecoration(
      labelText: label != '' ? label : null,
      hintText: '+7(___)___-____',
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: GeneralUtil.greenColor)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        borderSide: BorderSide(
            color: GeneralUtil.greenColor, width: 2), // Blue color when focused
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        borderSide: BorderSide(
            color: GeneralUtil.greenColor, width: 2), // Blue color when enabled
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 30),
    );
  }

  // passwordField
  Widget passwordField(TextEditingController _password, BuildContext context) {
    return TextField(
      keyboardType: TextInputType.phone,
      controller: _password,
      obscureText: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      decoration: InputDecoration(
        hintText: 'Купия соз',
        prefixText: ' ',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: GeneralUtil.mainColor)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          borderSide: BorderSide(
              color: GeneralUtil.mainColor,
              width: 2), // Blue color when focused
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          borderSide: BorderSide(
              color: GeneralUtil.mainColor,
              width: 2), // Blue color when enabled
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      ),
    );
  }

  // enterButton
  Widget enterButton(
    BuildContext context,
    TextEditingController _username,
    TextEditingController _password,
  ) {
    return TextButton(
      style: flatButtonStyle,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromRGBO(254, 152, 105, 1),
              Color.fromRGBO(254, 80, 0, 1),
            ],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Center(
          child: Text(
            'Войти',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onPressed: () => {
        // onClickEnter(context, _username, _password),
      },
    );
  }

  // Navigator
  void navigateToMainPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RoadMap(selectedIndx: 0, state: 0,),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
          (route) => false,
    );
  }

  // OnClick
  String? onClickEnter(BuildContext context, TextEditingController _username,
      TextEditingController _password) {
    String? response = '';
    if (isNotEmpty(_username) && isNotEmpty(_password)) {
      getAccessToken(_username.text, _password.text, context).then(
        (value) => {
          response = value,
        },
      );
    }
    return response;
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: Size(88, 36),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
  );

  // EmptyChecker
  bool isNotEmpty(TextEditingController text) {
    if (text.text.length > 1) {
      return true;
    }
    return false;
  }

  // AccessToken
  Future<String?> getAccessToken(
      String username, String password, BuildContext context) async {
    String response = '';
    String phone = username.replaceAll(RegExp(r'[ ()-]'), '');
    phone = phone.replaceFirst("+7", "8");
    AuthService().getToken(phone, password).then((res) => {
          if (res != null)
            {
              savePreferences(res.accessToken),
              navigateToMainPage(context),
            }
          else
            {
              response = 'Вход невозможен',
            }
        });
    return response;
  }

  void savePreferences(String accessToken) async {
    await _storage.write(key: 'auth_token', value: accessToken);
    await _storage.write(key: 'auth_saved_at', value: DateTime.now().toIso8601String());
  }
}
