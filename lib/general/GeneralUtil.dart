import 'package:flutter/material.dart';
import 'dart:ui';

class GeneralUtil {
  // token data
  static const username = 'username';
  static const password = 'password';
  static const accessToken = 'accessToken';

  // URL
  static const BASE_URL = "https://restart.brand-online.kz";

  // static const BASE_URL = "http://94.131.80.201:8000";


  // Colors
  static const drawerColor = "#262F40";

  static const mainColor = Color.fromRGBO(0, 130, 255, 1);
  static const blueColor = Color.fromRGBO(75, 167, 255, 1);
  static const greenColor = Color.fromRGBO(155, 208, 80, 1);
  static const greyColor = Color.fromRGBO(151, 151, 151, 1);
  static const orangeColor = Color.fromRGBO(255,108,54, 1);
  static const blackColor = Color.fromRGBO(61,61,1, 1);
  static const yellowColor = Color.fromRGBO(252,170,23, 1);
  static const redColor = Color.fromRGBO(255,62,62, 1);
  static const pinkColor = Color.fromRGBO(192, 125, 243, 1);
  static const yellowOrangeColor = Color.fromRGBO(255, 217, 66, 1);
  static const darkBlueColor = Color.fromRGBO(66, 51, 153, 1);




  static ButtonStyle getBlueButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size(
        MediaQuery.of(context).size.width * 0.8,
        57,
      ),
      foregroundColor: GeneralUtil.mainColor,
      backgroundColor: GeneralUtil.mainColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static ButtonStyle getGreenButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size(
        MediaQuery.of(context).size.width * 0.8,
        57,
      ),
      foregroundColor: GeneralUtil.greenColor,
      backgroundColor: GeneralUtil.greenColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static ButtonStyle getWhiteButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size(
        MediaQuery.of(context).size.width * 0.8,
        57,
      ),
      foregroundColor: Colors.white,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static ButtonStyle getWhiteButtonBorderStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size(
        MediaQuery.of(context).size.width * 0.8,
        57,
      ),
      foregroundColor: Colors.white,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: GeneralUtil.mainColor,
          width: 2,
        ),
      ),
    );
  }

  static InputDecoration getTextFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
        borderSide: BorderSide(color: GeneralUtil.mainColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 30),
    );
  }
}
