import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../general/MainEntryPage.dart';
import '../../entity/SignEntity.dart';
import '../../service/auth_service.dart';

class SignScreenWidget {
  // SpaceBreaker
  Widget spaceBreaker(double breakerHeight) {
    return Container(
      height: breakerHeight,
    );
  }

  Widget roleField(TextEditingController _password, BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.remove_red_eye),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Роль',
        hintStyle: TextStyle(color: Colors.grey),
        prefixText: ' ',
        suffixStyle: const TextStyle(color: Colors.green),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.02,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget nameField(TextEditingController _password, BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.remove_red_eye),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Имя',
        hintStyle: TextStyle(color: Colors.grey),
        prefixText: ' ',
        suffixStyle: const TextStyle(color: Colors.green),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.02,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget surnameField(TextEditingController _password, BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.remove_red_eye),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Фамилия',
        hintStyle: TextStyle(color: Colors.grey),
        prefixText: ' ',
        suffixStyle: const TextStyle(color: Colors.green),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.02,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget codeField(TextEditingController _password, BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.remove_red_eye),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Код',
        hintStyle: TextStyle(color: Colors.grey),
        prefixText: ' ',
        suffixStyle: const TextStyle(color: Colors.green),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.02,
        letterSpacing: 1.0,
      ),
    );
  }

  // Logo Tite
  Widget logoTitle(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            "Войдите или",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "зарегистрируйтесь",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // EnterButton
  Widget enterButton(
    BuildContext context,
    TextEditingController _username,
    TextEditingController _code,
    TextEditingController _name,
    TextEditingController _surname,
    TextEditingController _password,
    TextEditingController _role,
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
        onClickEnter(
            context, _username, _code, _name, _surname, _password, _role),
      },
    );
  }

  void onClickEnter(
    BuildContext context,
    TextEditingController _username,
    TextEditingController _code,
    TextEditingController _name,
    TextEditingController _surname,
    TextEditingController _password,
    TextEditingController _role,
  ) {
    {
      if (isNotEmpty(_username) && isNotEmpty(_password)) {
        signIn(_username.text, _code.text, _name.text, _surname.text,
            _password.text, _role.text, context);
      }
    }
  }

  void signIn(String username, String code, String name, String surname,
      String password, String role, BuildContext context) async {
    // navigateToMainPage(context);
    SignEntity entity =
        new SignEntity(username, code, name, surname, password, role, "");
    AuthService()
        .verifyAndSign(entity)
        .then((res) => {
              if (res != null && res.message == 'User created successfully.')
                {
                  navigateToMainPage(context),
                }
              else
                {
                  _showMyDialog(context),
                }
            });
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text('Вход невозможен!'),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.pinkAccent,
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToMainPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainEntryPage(),
      ),
          (Route<dynamic> route) => false,
    );
  }

  bool isNotEmpty(TextEditingController text) {
    if (text.text.length > 1) {
      return true;
    }
    return false;
  }

  Widget usernameField(TextEditingController _username, BuildContext context) {
    return TextField(
      controller: _username,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.person),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Логин',
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

  // passwordField
  Widget passwordField(TextEditingController _password, BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
      ],
      onChanged: (String iinChanged) {},
      decoration: new InputDecoration(
        suffixIcon: Icon(Icons.remove_red_eye),
        border: new UnderlineInputBorder(
            borderSide: new BorderSide(color: Colors.black)),
        hintText: 'Пароль',
        hintStyle: TextStyle(color: Colors.grey),
        prefixText: ' ',
        suffixStyle: const TextStyle(color: Colors.green),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.02,
        letterSpacing: 1.0,
      ),
    );
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: Size(88, 36),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16),
  );

  // SignButton
  Widget registrationButton(BuildContext context) {
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
            'Зарегестрироваться',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onPressed: () => {},
    );
  }
}
