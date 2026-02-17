import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:brand_online/roadMap/entity/SubjectModel.dart';
import 'package:brand_online/roadMap/entity/daily_entity.dart';

import '../../general/GeneralUtil.dart';
import '../entity/ControlExam.dart';
import '../entity/ControlExamResponse.dart';
import '../entity/ProfileController.dart';
import '../entity/TaskEntity.dart';

class TaskSubmitResult {
  final bool isCorrect;
  final int taskCashback;

  TaskSubmitResult({required this.isCorrect, required this.taskCashback});
}

/// Берёт процент из ответа: если есть attempt.percentage (общий % по сынақу) — используем его, иначе — верхнеуровневый percentage (по одному заданию).
double _percentageFromSubmitResponse(Map<String, dynamic> data) {
  final attempt = data['attempt'];
  if (attempt != null && attempt is Map && attempt['percentage'] != null) {
    return (attempt['percentage'] as num).toDouble();
  }
  return (data['percentage'] ?? 0).toDouble();
}

class TaskService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: GeneralUtil.BASE_URL,
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      validateStatus: (code) => code != null && code < 400,
    ),
  );

  // ===================== ПУБЛИЧНЫЕ МЕТОДЫ ОТПРАВКИ ОТВЕТОВ =====================

  Future<TaskSubmitResult> submitFillAnswer({
    required int lessonId,
    required String answer,
    required bool isRepeat,
    required bool isExamMode,
    required int mockExamId,
    required Function(String) updateMultiplier,
    required int state,
    required Function(Task) updateTask,
    required bool usedHelp,
    required VoidCallback onNext,
    required Function(String) onError,
    required bool isLast,
    bool dailyReview = false,
    required bool isCash,
    bool dailySubjectMode = false,
    Task? currentTaskForRetry,
    required Function(
        int score,
        int percentage,
        int strike,
        int temporaryBalance,
        double factor,
        int money,
        bool isCash,
        int taskCashback,
        int totalCashback,
        ) showResultScreen,
    required Function(int taskCashback, bool answer) showAnswer,

    CancelToken? cancelToken,
    int maxRetries = 3,
    Duration perAttemptTimeout = const Duration(seconds: 15),
    Duration totalTimeout = const Duration(seconds: 45),
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    try {
      final Response response = await _requestWithRetry<dynamic>(
            (ct) => _dio.post(
          '/edu/task/$lessonId/submit/fill/',
          data: {
            "answer": answer,
            "daily_subject_mode": dailySubjectMode,
            "videosolution_watched": false,
            "answer_watched": false,
            "state": state,
            if (dailyReview) "daily_review_mode": true,
            if (usedHelp) "used_help": true,
            if (isRepeat) "repeat_mode": true,
            if (isExamMode) "mock_exam_mode": true,
            if (isExamMode) "mock_exam_id": mockExamId,
            "last": isLast,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
        cancelToken: cancelToken,
        maxRetries: maxRetries,
        perAttemptTimeout: perAttemptTimeout,
        totalTimeout: totalTimeout,
      );

      print('response: ${response.data}');

      final Map<String, dynamic> responseData = response.data;
      final bool isCorrect = responseData['result'] == true;
      final int score = response.data["points"] ?? 0;
      final double percentage = _percentageFromSubmitResponse(responseData);
      final bool isStrike = responseData["strike"] ?? false;
      final taskData = response.data["task"];
      final double factor = (response.data["factor"] ?? 0).toDouble();
      final int money = response.data["money"] ?? 0;
      final int taskCashback = response.data["task_cashback"] ?? 0;
      final int totalCashback = response.data["total_cashback"] ?? 0;
      final int temporaryBalance = response.data["temporary_balance"] ?? 0;

      final bool keepLastForExamResult = isExamMode && isLast && !isCorrect;
      if (taskData != null) {
        final Task retryTask = Task.fromJson(taskData);
        updateTask(retryTask);
        if (!keepLastForExamResult) isLast = false;
      } else if (isExamMode && !isCorrect && currentTaskForRetry != null) {
        updateTask(currentTaskForRetry);
        if (!keepLastForExamResult) isLast = false;
      }

      if (responseData.containsKey('profile') &&
          responseData['profile'] != null &&
          responseData['profile']['multiplier'] != null) {
        final mult = responseData['profile']['multiplier'].toString();
        updateMultiplier(mult);
        ProfileController.updateMultiplier(mult);
      }

      int strike = 0;
      if (isStrike &&
          responseData.containsKey('profile') &&
          responseData['profile'] != null &&
          responseData['profile']['strike'] != null) {
        strike = responseData['profile']['strike'] ?? 0;
      }

      await showAnswer(taskCashback, isCorrect);

      if (keepLastForExamResult) {
        await showResultScreen(
          score,
          percentage.toInt(),
          strike,
          temporaryBalance,
          factor,
          money,
          isCash,
          taskCashback,
          totalCashback,
        );
        return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
      }
      if (isCash) {
        if (isLast) {
          await showResultScreen(
            score,
            percentage.toInt(),
            strike,
            temporaryBalance,
            factor,
            money,
            isCash,
            taskCashback,
            totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      if (isCorrect) {
        if (isLast) {
          await showResultScreen(
            score,
            percentage.toInt(),
            strike,
            temporaryBalance,
            factor,
            money,
            isCash,
            taskCashback,
            totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
    } catch (e) {
      onError(_friendlyMessage(e));
      return TaskSubmitResult(isCorrect: false, taskCashback: 0);
    }
  }

  Future<TaskSubmitResult> submitMultipleChoice({
    required int lessonId,
    required bool isLast,
    required int? selectedChoice,
    required int state,
    required bool isRepeat,
    required bool isExamMode,
    required int mockExamId,
    required Function(String) updateMultiplier,
    required Function(Task) updateTask,
    required bool usedHelp,
    required VoidCallback onNext,
    required Function(String) onError,
    bool dailyReview = false,
    bool dailySubjectMode = false,
    required bool isCash,
    required Function(
        int score,
        int percentage,
        int strike,
        int temporaryBalance,
        double factor,
        int money,
        bool isCash,
        int taskCashback,
        int totalCashback,
        ) showResultScreen,
    required Function(int taskCashback, bool answer) showAnswer,
    Task? currentTaskForRetry,

    CancelToken? cancelToken,
    int maxRetries = 3,
    Duration perAttemptTimeout = const Duration(seconds: 15),
    Duration totalTimeout = const Duration(seconds: 45),
  }) async {
    if (selectedChoice == null) {
      onError("Выберите вариант ответа!");
      return TaskSubmitResult(isCorrect: false, taskCashback: 0);
    }

    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    try {
      final Response response = await _requestWithRetry<dynamic>(
            (ct) => _dio.post(
          '/edu/task/$lessonId/submit/multiple/',
          data: {
            "choice_id": selectedChoice,
            "daily_subject_mode": dailySubjectMode,
            "videosolution_watched": false,
            "answer_watched": false,
            "state": state,
            if (dailyReview) "daily_review_mode": true,
            if (usedHelp) "used_help": true,
            if (isRepeat) "repeat_mode": true,
            if (isExamMode) "mock_exam_mode": true,
            if (isExamMode) "mock_exam_id": mockExamId,
            "last": isLast,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
        cancelToken: cancelToken,
        maxRetries: maxRetries,
        perAttemptTimeout: perAttemptTimeout,
        totalTimeout: totalTimeout,
      );

      final responseData = response.data;
      final bool isCorrect = responseData['result'] == true;
      final int score = response.data["points"] ?? 0;
      final double percentage = _percentageFromSubmitResponse(responseData);
      final bool isStrike = responseData["strike"] ?? false;
      final taskData = response.data["task"];
      final double factor = (response.data["factor"] ?? 0).toDouble();
      final int money = response.data["money"] ?? 0;
      final int taskCashback = response.data["task_cashback"] ?? 0;
      final int totalCashback = response.data["total_cashback"] ?? 0;
      final int temporaryBalance = response.data["temporary_balance"] ?? 0;

      final bool keepLastForExamResult = isExamMode && isLast && !isCorrect;
      if (taskData != null) {
        final Task retryTask = Task.fromJson(taskData);
        updateTask(retryTask);
        if (!keepLastForExamResult) isLast = false;
      } else if (isExamMode && !isCorrect && currentTaskForRetry != null) {
        updateTask(currentTaskForRetry);
        if (!keepLastForExamResult) isLast = false;
      }

      if (responseData.containsKey('profile') &&
          responseData['profile'] != null &&
          responseData['profile']['multiplier'] != null) {
        final mult = responseData['profile']['multiplier'].toString();
        updateMultiplier(mult);
        ProfileController.updateMultiplier(mult);
      }

      int strike = 0;
      if (isStrike &&
          responseData.containsKey('profile') &&
          responseData['profile'] != null &&
          responseData['profile']['strike'] != null) {
        strike = responseData['profile']['strike'] ?? 0;
      }

      await showAnswer(taskCashback, isCorrect);

      if (keepLastForExamResult) {
        await showResultScreen(
          score,
          percentage.toInt(),
          strike,
          temporaryBalance,
          factor,
          money,
          isCash,
          taskCashback,
          totalCashback,
        );
        return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
      }
      if (isCash) {
        if (isLast) {
          await showResultScreen(
            score,
            percentage.toInt(),
            strike,
            temporaryBalance,
            factor,
            money,
            isCash,
            taskCashback,
            totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      if (isCorrect) {
        if (isLast) {
          await showResultScreen(
            score,
            percentage.toInt(),
            strike,
            temporaryBalance,
            factor,
            money,
            isCash,
            taskCashback,
            totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
    } catch (e) {
      onError(_friendlyMessage(e));
      return TaskSubmitResult(isCorrect: false, taskCashback: 0);
    }
  }

  Future<TaskSubmitResult> submitMatchingPairs({
    required int lessonId,
    required bool isLast,
    required bool isRepeat,
    required List<Map<String, int>> matches,
    required bool isExamMode,
    required int mockExamId,
    required Function(String) updateMultiplier,
    required Function(Task) updateTask,
    required VoidCallback onNext,
    required bool usedHelp,
    required int state,
    required bool isCash,
    bool dailyReview = false,
    bool dailySubjectMode = false,
    required Function(String) onError,
    required Function(
        int score,
        int percentage,
        int strike,
        int temporaryBalance,
        double factor,
        int money,
        bool isCash,
        int taskCashback,
        int totalCashback,
        ) showResultScreen,
    required Function(int taskCashback, bool answer) showAnswer,
    Task? currentTaskForRetry,

    CancelToken? cancelToken,
    int maxRetries = 3,
    Duration perAttemptTimeout = const Duration(seconds: 15),
    Duration totalTimeout = const Duration(seconds: 45),
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    final Map<String, dynamic> requestData = {
      "matches": matches,
      "daily_subject_mode": dailySubjectMode,
      "videosolution_watched": false,
      "answer_watched": false,
      "state": state,
      if (dailyReview) "daily_review_mode": true,
      if (usedHelp) "used_help": true,
      if (isRepeat) "repeat_mode": true,
      if (isExamMode) "mock_exam_mode": true,
      if (isExamMode) "mock_exam_id": mockExamId,
      "last": isLast,
    };

    try {
      final Response response = await _requestWithRetry<dynamic>(
            (ct) => _dio.post(
          '/edu/task/$lessonId/submit/matching/',
          data: requestData,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
        cancelToken: cancelToken,
        maxRetries: maxRetries,
        perAttemptTimeout: perAttemptTimeout,
        totalTimeout: totalTimeout,
      );

      final responseData = response.data;
      final bool isCorrect = responseData["result"] == true;
      final int score = response.data["points"] ?? 0;
      final double percentage = _percentageFromSubmitResponse(responseData);
      final bool isStrike = responseData["strike"] ?? false;
      final taskData = response.data["task"];
      final double factor = (response.data["factor"] ?? 0).toDouble();
      final int money = response.data["money"] ?? 0;
      final int taskCashback = response.data["task_cashback"] ?? 0;
      final int totalCashback = response.data["total_cashback"] ?? 0;
      final int temporaryBalance = response.data["temporary_balance"] ?? 0;

      final bool keepLastForExamResult = isExamMode && isLast && !isCorrect;
      if (taskData != null) {
        final Task retryTask = Task.fromJson(taskData);
        updateTask(retryTask);
        if (!keepLastForExamResult) isLast = false;
      } else if (isExamMode && !isCorrect && currentTaskForRetry != null) {
        updateTask(currentTaskForRetry);
        if (!keepLastForExamResult) isLast = false;
      }

      if (responseData.containsKey('profile') &&
          responseData['profile'] != null &&
          responseData['profile']['multiplier'] != null) {
        final mult = responseData['profile']['multiplier'].toString();
        updateMultiplier(mult);
        ProfileController.updateMultiplier(mult);
      }

      int strike = 0;
      if (isStrike &&
          responseData.containsKey('profile') &&
          responseData['profile'] != null &&
          responseData['profile']['strike'] != null) {
        strike = responseData['profile']['strike'] ?? 0;
      }

      await showAnswer(taskCashback, isCorrect);

      if (keepLastForExamResult) {
        await showResultScreen(
          score,
          percentage.toInt(),
          strike,
          temporaryBalance,
          factor,
          money,
          isCash,
          taskCashback,
          totalCashback,
        );
        return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
      }
      if (isCash) {
        if (isLast) {
          await showResultScreen(
            score,
            percentage.toInt(),
            strike,
            temporaryBalance,
            factor,
            money,
            isCash,
            taskCashback,
            totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      if (isCorrect) {
        if (isLast) {
          await showResultScreen(
            score,
            percentage.toInt(),
            strike,
            temporaryBalance,
            factor,
            money,
            isCash,
            taskCashback,
            totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
    } catch (e) {
      onError(_friendlyMessage(e));
      return TaskSubmitResult(isCorrect: false, taskCashback: 0);
    }
  }

  // --------------------- NEW: submitAnagram ---------------------
  Future<TaskSubmitResult> submitAnagram({
    required int lessonId,
    required List<String> segments,   // <-- порядок, выбранный пользователем
    required bool isLast,
    required bool isRepeat,
    required bool usedHelp,
    required int state,
    required bool isCash,
    bool dailyReview = false,
    bool dailySubjectMode = false,
    required bool isExamMode,
    required int mockExamId,
    required Function(String) updateMultiplier,
    required Function(Task) updateTask,
    required VoidCallback onNext,
    required Function(String) onError,
    required Future<void> Function(
        int score,
        int percentage,
        int strike,
        int temporaryBalance,
        double factor,
        int money,
        bool isCash,
        int taskCashback,
        int totalCashback,
        ) showResultScreen,
    required Future<void> Function(int taskCashback, bool answer) showAnswer,
    Task? currentTaskForRetry,

    CancelToken? cancelToken,
    int maxRetries = 3,
    Duration perAttemptTimeout = const Duration(seconds: 15),
    Duration totalTimeout = const Duration(seconds: 45),
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    final Map<String, dynamic> data = {
      "segments": segments, // <-- ВАЖНО! отправляем строки
      "daily_subject_mode": dailySubjectMode,
      "videosolution_watched": false,
      "answer_watched": false,
      "state": state,
      if (dailyReview) "daily_review_mode": true,
      if (usedHelp) "used_help": true,
      if (isRepeat) "repeat_mode": true,
      if (isExamMode) "mock_exam_mode": true,
      if (isExamMode) "mock_exam_id": mockExamId,
      "last": isLast,
    };

    try {
      final response = await _requestWithRetry<dynamic>(
            (ct) => _dio.post(
          '/edu/task/$lessonId/submit/anagram/',
          data: data,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
        cancelToken: cancelToken,
        maxRetries: maxRetries,
        perAttemptTimeout: perAttemptTimeout,
        totalTimeout: totalTimeout,
      );

      final res = response.data;
      final bool isCorrect = res['result'] == true;
      final int score = res["points"] ?? 0;
      final double percentage = _percentageFromSubmitResponse(res);
      final bool isStrike = res["strike"] ?? false;
      final taskData = res["task"];
      final double factor = (res["factor"] ?? 0).toDouble();
      final int money = res["money"] ?? 0;
      final int taskCashback = res["task_cashback"] ?? 0;
      final int totalCashback = res["total_cashback"] ?? 0;
      final int temporaryBalance = res["temporary_balance"] ?? 0;

      final bool keepLastForExamResult = isExamMode && isLast && !isCorrect;
      if (taskData != null) {
        final Task retryTask = Task.fromJson(taskData);
        updateTask(retryTask);
        if (!keepLastForExamResult) isLast = false;
      } else if (isExamMode && !isCorrect && currentTaskForRetry != null) {
        updateTask(currentTaskForRetry);
        if (!keepLastForExamResult) isLast = false;
      }

      if (res.containsKey('profile') &&
          res['profile'] != null &&
          res['profile']['multiplier'] != null) {
        final mult = res['profile']['multiplier'].toString();
        updateMultiplier(mult);
        ProfileController.updateMultiplier(mult);
      }

      int strike = 0;
      if (isStrike &&
          res.containsKey('profile') &&
          res['profile'] != null &&
          res['profile']['strike'] != null) {
        strike = res['profile']['strike'] ?? 0;
      }

      await showAnswer(taskCashback, isCorrect);

      if (keepLastForExamResult) {
        await showResultScreen(
          score, percentage.toInt(), strike, temporaryBalance,
          factor, money, isCash, taskCashback, totalCashback,
        );
        return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
      }
      if (isCash) {
        if (isLast) {
          await showResultScreen(
            score, percentage.toInt(), strike, temporaryBalance,
            factor, money, isCash, taskCashback, totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      if (isCorrect) {
        if (isLast) {
          await showResultScreen(
            score, percentage.toInt(), strike, temporaryBalance,
            factor, money, isCash, taskCashback, totalCashback,
          );
          return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
        }
        onNext();
      }
      return TaskSubmitResult(isCorrect: isCorrect, taskCashback: taskCashback);
    } catch (e) {
      onError(_friendlyMessage(e));
      return TaskSubmitResult(isCorrect: false, taskCashback: 0);
    }
  }

  // ----------------------------------------------------------

  // ===================== ПРОЧИЕ API =====================

  Future<ControlExamResponse> fetchControlTasks({
    CancelToken? cancelToken,
    int maxRetries = 3,
    Duration perAttemptTimeout = const Duration(seconds: 15),
    Duration totalTimeout = const Duration(seconds: 45),
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    final response = await _requestWithRetry<dynamic>(
          (ct) => _dio.get(
        '/edu/cashback/control-tasks/',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        cancelToken: ct,
      ),
      cancelToken: cancelToken,
      maxRetries: maxRetries,
      perAttemptTimeout: perAttemptTimeout,
      totalTimeout: totalTimeout,
    );

    if (response.statusCode == 200) {
      return ControlExamResponse.fromJson(response.data);
    } else {
      throw Exception('Қате: ${response.statusCode}');
    }
  }

  Future<List<SubjectModel>> getMyCourses({
    CancelToken? cancelToken,
    int maxRetries = 2,
    Duration perAttemptTimeout = const Duration(seconds: 7),
    Duration totalTimeout = const Duration(seconds: 18),
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    try {
      final response = await _requestWithRetry<dynamic>(
            (ct) => _dio.get(
          '/edu/my-courses/',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
        cancelToken: cancelToken,
        maxRetries: maxRetries,
        perAttemptTimeout: perAttemptTimeout,
        totalTimeout: totalTimeout,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => SubjectModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("Error: ${e.response?.data}");
      return [];
    }
  }

  Future<DailyEntity?> getDailyTasks(int gradeId) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');
    try {
      final response = await _requestWithRetry<dynamic>(
            (ct) => _dio.get(
          '/edu/daily-subject/grade/$gradeId/tasks',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
      );
      
    return DailyEntity.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<RestartLessonsResponse?> getRestartLessons({
    CancelToken? cancelToken,
    int maxRetries = 2,
    Duration perAttemptTimeout = const Duration(seconds: 7),
    Duration totalTimeout = const Duration(seconds: 18),
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    try {
      final response = await _requestWithRetry<dynamic>(
            (ct) => _dio.get(
          '/edu/restart/',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          cancelToken: ct,
        ),
        cancelToken: cancelToken,
        maxRetries: maxRetries,
        perAttemptTimeout: perAttemptTimeout,
        totalTimeout: totalTimeout,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return RestartLessonsResponse.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print("Ошибка при получении уроков повторения: $e");
      return null;
    }
  }

  /// GET /edu/mock-exams/:id/tasks — задания mock exam.
  Future<MockExamTasksResponse?> getMockExamTasks(
    int examId, {
    CancelToken? cancelToken,
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');
    if (token == null) return null;

    try {
      final response = await _dio.get(
        '/edu/mock-exams/$examId/tasks/',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return MockExamTasksResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Ошибка при получении заданий mock exam: $e");
      return null;
    }
  }

  Future<String> sendReport({
    String? taskId,
    String? message
  }) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    final String? token = await storage.read(key: 'auth_token');

    try {
      final response = await _dio.post(
        "/edu/task/$taskId/report/",
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        data: {
          "description": message,
        },
      );

      print("STATUS: ${response.statusCode}");
      print("DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "success";
      } else {
        return "error";
      }
    } catch (e, s) {
      return "error $e $s";
    }
  }
  Future<String> sendFcmToken({
      String? fcmToken,
    }) async {
      final storage = FlutterSecureStorage(
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      final String? token = await storage.read(key: 'auth_token');

      try {
        final response = await _dio.post(
          "/auth/device-token/",
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
          data: {
            "firebase_device_token": fcmToken,
          },
        );

        print("FCM SENDED STATUS: ${response.statusCode}");
        print("DATA: ${response.data}");
        print("TOKEN: ${fcmToken}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          return "fcm sended successfully";
        } else {
          return "error";
        }
      } catch (e, s) {
        return "error $e $s";
      }
    }

  // ===================== ХЕЛПЕРЫ =====================

  Future<Response<T>> _requestWithRetry<T>(
      Future<Response<T>> Function(CancelToken ct) requestFn, {
        CancelToken? cancelToken,
        int maxRetries = 3,
        Duration perAttemptTimeout = const Duration(seconds: 15),
        Duration totalTimeout = const Duration(seconds: 45),
      }) async {
    final started = DateTime.now();
    int attempt = 0;
    DioException? lastErr;
    final ct = cancelToken ?? CancelToken();

    while (true) {
      attempt++;
      try {
        final res = await requestFn(ct).timeout(perAttemptTimeout);
        return res;
      } on TimeoutException catch (e) {
        lastErr = DioException(
          requestOptions: RequestOptions(path: 'timeout'),
          error: e,
          type: DioExceptionType.connectionTimeout,
        );
      } on DioException catch (e) {
        lastErr = e;

        if (e.type == DioExceptionType.cancel) rethrow;

        final int? code = e.response?.statusCode;
        final bool isNetwork =
            e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.connectionError ||
                (e.type == DioExceptionType.unknown && e.error is SocketException);

        final bool isRetriableServer =
            e.type == DioExceptionType.badResponse &&
                code != null &&
                code >= 500 &&
                code < 600;

        if (!(isNetwork || isRetriableServer)) {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }

      final elapsed = DateTime.now().difference(started);
      if (attempt > maxRetries || elapsed >= totalTimeout) {
        throw lastErr;
        // ??
            // DioException(
            //   requestOptions: RequestOptions(path: 'unknown'),
            //   error: 'Network error',
            //   type: DioExceptionType.unknown,
            // );
      }

      final backoff = Duration(milliseconds: 500 * (1 << (attempt - 1)));
      await Future.delayed(backoff);
    }
  }

  String _friendlyMessage(Object e) {
    if (e is TimeoutException) {
      return 'Уақыт аяқталды. Қайта көріңіз.';
    }
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.cancel:
          return 'Операция тоқтатылды.';
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.connectionError:
          return 'Интернетке қосылу әлсіз. Тағы да көріңіз.';
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode ?? 0;
          if (code >= 500) {
            return 'Сервер уақытша қолжетімсіз ($code). Кейінірек көріңіз.';
          }
          if (code >= 400) {
            return 'Қате ($code). Дұрыс енгізілгенін тексеріңіз немесе кейінірек қайталап көріңіз.';
          }
          return 'Қате жауап. Кейінірек көріңіз.';
        case DioExceptionType.badCertificate:
          return 'Қауіпсіздік сертификаты қате.';
        case DioExceptionType.unknown:
          if (e.error is SocketException) {
            return 'Интернетке қосылу әлсіз. Тағы да көріңіз.';
          }
          return '';
      }
    }
    return '';
  }
}
