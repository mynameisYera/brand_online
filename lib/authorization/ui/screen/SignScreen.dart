import 'package:flutter/material.dart';

import '../../../general/MainEntryPage.dart';
import '../../service/auth_service.dart';
import '../widget/SignScreenWidget.dart';

class SignScreen extends StatefulWidget {

  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  TextEditingController _username = TextEditingController();

  TextEditingController _code = TextEditingController();

  TextEditingController _name = TextEditingController();

  TextEditingController _surname = TextEditingController();

  TextEditingController _password = TextEditingController();

  TextEditingController _role = TextEditingController();

  SignScreenWidget widgets = new SignScreenWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: null,
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    widgets
                        .spaceBreaker(MediaQuery.of(context).size.height * 0.1),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.03),
                      child: widgets.logoTitle(context),
                    ),
                    widgets
                        .spaceBreaker(MediaQuery.of(context).size.height * 0.05),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widgets.usernameField(_username, context),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widgets.codeField(_code, context),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widgets.nameField(_name, context),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widgets.surnameField(_surname, context),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widgets.passwordField(_password, context),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: widgets.roleField(_role, context),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.17,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: widgets.enterButton(context, _username, _code, _name,
                          _surname, _password, _role),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigator
  void navigateToMainPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainEntryPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // EmptyChecker
  bool isNotEmpty(TextEditingController text) {
    if (text.text.length > 1) {
      return true;
    }
    return false;
  }

  // AccessToken
  void getAccessToken(
      String username, String password, BuildContext context) async {
    navigateToMainPage(context);

    AuthService().getToken(username, password).then((res) => {
          if (res != null)
            {
              savePreferences(username, password, res.accessToken),
              navigateToMainPage(context),
            }
          else
            {
              print('ERROR'),
              _showMyDialog(context),
            }
        });
  }

  //SavePreferences
  void savePreferences(
      String username, String password, String accessToken) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.setString(
    //   GeneralUtil.username,
    //   username,
    // );
    // await preferences.setString(
    //   GeneralUtil.password,
    //   password,
    // );
    // await preferences.setString(
    //   GeneralUtil.accessToken,
    //   accessToken,
    // );
  }

  //Error Dialog
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
}
