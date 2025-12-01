// ignore_for_file: unused_local_variable

import '../../authorization/entity/ErrorResponse.dart';
import '../../authorization/entity/VerificationCodeResponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../general/GeneralUtil.dart';
import '../entity/TaskEntity.dart';

class YoutubeService {
  // final _storage = const FlutterSecureStorage();

  Future<VerificationCodeResponse?> videoWatched(int lessonId) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      response = await _dio.post(
        '/edu/lesson/$lessonId/watched/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPassword(e.response?.data);
    }
    print(response);
    if (response == null) {
      return VerificationCodeResponse(errorResponse!.message.toString(), null, null);
    } else {
      return VerificationCodeResponse.fromJson(response.data);
    }
  }

  Future<DataModel?> getTasks(int lessonId, int groupId) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      response = await _dio.get(
        '/edu/lesson/$lessonId/group/$groupId/tasks/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPassword(e.response?.data);
    }
    print(response);
    return (response != null && response.data != null)
        ? DataModel.fromJson(response.data)
        : null;
  }

  Future<DataModel?> getCashTasks() async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      response = await _dio.get(
        '/edu/cashback/control-tasks/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPassword(e.response?.data);
    }
    print(response);
    return (response != null && response.data != null)
        ? DataModel.fromJson(response.data)
        : null;
  }

  Future<DataModel?> getDailyReviewTasks() async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      response = await _dio.get(
        '/edu/daily-review/tasks/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPassword(e.response?.data);
    }
    print(response);
    return (response != null && response.data != null)
        ? DataModel.fromJson(response.data)
        : null;
  }

  Future<DataModel?> getRepeatTasks(int lessonId) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      response = await _dio.get(
        '/edu/restart/lesson/$lessonId/tasks/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPassword(e.response?.data);
    }
    print(response);
    return (response != null && response.data != null)
        ? DataModel.fromJson(response.data)
        : null;
  }
}
