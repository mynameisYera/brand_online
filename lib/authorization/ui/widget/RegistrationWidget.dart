import 'package:flutter/cupertino.dart';

import '../../entity/SignEntity.dart';
import '../../service/auth_service.dart';

class RegistrationWidget {
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Бос болмауы керек';
    }
    if (value.length < 2 || value.length > 50) {
      return 'Аты және тегі 2 және 50 таңбадан тұруы керек.';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Бос болмауы керек';
    }
    if (value.length < 11) {
      return 'Телефон нөмірі 11 таңбадан тұруы керек.';
    }
    return null;
  }

  String? checkPage1(
      TextEditingController firstname, TextEditingController lastname) {
    if (validateName(firstname.text) != null) {
      return validateName(firstname.text);
    }
    if (validateName(lastname.text) != null) {
      return validateName(lastname.text);
    }
    return '';
  }

  String? checkPage2(TextEditingController phoneNumber) {
    if (validatePhoneNumber(phoneNumber.text) != null) {
      return validatePhoneNumber(phoneNumber.text);
    }
    return '';
  }

  Future<String?> signIn(String username, String code, String name, String surname,
      String password, String role, BuildContext context) async {
    // navigateToMainPage(context);
    SignEntity entity =
    new SignEntity(username, code, name, surname, password, role, "");
    String? response = '';
    AuthService()
        .verifyAndSign(entity)
        .then((res) => {
      if (res != null && res.message == 'User created successfully.')
        {
          response = '',
        }
      else
        {
          response = res?.message,
        }
    });
    return response;
  }
}
