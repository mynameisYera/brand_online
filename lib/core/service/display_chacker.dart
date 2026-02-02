import 'package:flutter/material.dart';

class DisplayChacker {
  static bool isDisplay(BuildContext context) {
    return MediaQuery.of(context).size.width > 600 ? false : true;
  }
}