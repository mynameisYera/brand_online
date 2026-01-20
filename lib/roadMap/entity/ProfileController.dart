import 'dart:math';
import 'package:flutter/material.dart';

import '../../authorization/entity/ProfileResponse.dart';

class ProfileController {
  static final ValueNotifier<String> multiplierNotifier = ValueNotifier<String>("1");

  static void updateMultiplier(String newMultiplier) {
    multiplierNotifier.value = newMultiplier;
  }
  // добавляем:
  static final repeatLessonsCountNotifier = ValueNotifier<int>(0);

  static void updateFromProfile(ProfileResponse p) {
    multiplierNotifier.value = p.multiplier.toString();
    final serverCount = p.repeatLessonsCount ?? 0;
    repeatLessonsCountNotifier.value = max(
      repeatLessonsCountNotifier.value,
      serverCount,
    );
  }

  static void setRepeatCount(int v) => repeatLessonsCountNotifier.value = v;
  static void incRepeat() => repeatLessonsCountNotifier.value++;
  static void decRepeat() =>
      repeatLessonsCountNotifier.value =
          (repeatLessonsCountNotifier.value - 1).clamp(0, 1 << 31);

}