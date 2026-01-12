import 'package:flutter/material.dart';
import 'package:brand_online/core/app_colors.dart';

class TextStyles {
  static TextStyle regular(Color? color) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );
  static TextStyle medium(Color? color) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color ?? AppColors.black,
  );
  static TextStyle semibold(Color? color, {double? fontSize}) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: fontSize ?? 16,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.black,
  );
  static TextStyle bold(Color? color, {double? fontSize}) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: fontSize ?? 22,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.black,
  );
}