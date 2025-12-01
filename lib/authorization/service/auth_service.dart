import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/loggers/l.dart';
import '../../general/GeneralUtil.dart';
import '../entity/AuthResponse.dart';
import '../entity/ErrorResponse.dart';
import '../entity/ProfileResponse.dart';
import '../entity/RoadMapResponse.dart';
import '../entity/SignEntity.dart';
import '../entity/VerificationCodeResponse.dart';

class AuthService {
  late String username;
  late String password;

  Future<AuthResponse?> getToken(String username, String password) async {
    
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;

    try {
      Map<String, String> body = {
        'username': username,
        'password': password,
      };
      response = await _dio.post(
        '/auth/login/',
        data: body,
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        L.e('error: ${e.response?.statusCode}');
      }

    }
    if (response != null && response.data != null) {
      L.info('auth', 'Авторизация успешна для пользователя: $username');
      return AuthResponse.fromJson(response.data);
    } else {
      L.error('auth', 'Авторизация не удалась для пользователя: $username');
      return null;
    }
  }

  Future<AuthResponse?> refreshToken(String token) async {
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;

    try {
      Map<String, String> body = {
        'refresh': token,
      };
      response = await _dio.post(
        '/auth/token/refresh/',
        data: body,
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        L.e('DioError: ${e.response?.statusCode}');
      }

    }
    return (response != null && response.data != null)
        ? AuthResponse.fromJsonAccess(response.data, "")
        : null;
  }

  Future<ProfileResponse?> getProfile(String token, BuildContext context) async {
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;

    try {
      response = await _dio.get(
        '/edu/profile/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        L.e('DioError: ${e.response?.statusCode}');
      }

    }
    if (response != null && response.data != null) {
      return ProfileResponse.fromJson(response.data);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
      return null;
    }
  }

  Future<LessonResponse?> getRoadMap(String token, BuildContext context) async {
    final dio = Dio(BaseOptions(baseUrl: GeneralUtil.BASE_URL));

    print("ACCOUNT TOKEN: $token");

    try {
      final res = await dio.get(
        '/edu/roadmap/',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (res.statusCode == 200 && res.data != null) {
        L.jsonPretty('roadmap Response', res.data);
        return LessonResponse.fromJson(res.data);
      }
    } on DioError catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 403 && context.mounted) {
        L.error('roadmap', 'Нет подписки: ${data?['message'] ?? 'Unknown'}');
        L.json('no subscription', data ?? {});

        return LessonResponse.noSubscription(
          title: data?['title'] ?? '',
          message: data?['message'] ?? '',
          buttonMessage: data?['button_message'] ?? '',
          whatsappUrl: data?['whatsapp_url'] ?? '',
        );
      }

      L.error('roadmap', 'Dio error: ${e.message}');
    } catch (e) {
      L.error('roadmap', 'Unexpected error: $e');
    }

    L.error('roadmap', 'Failed to load roadmap');
    return null;
  }


  Future<VerificationCodeResponse?> getVerificationCode(String phone) async {
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      Map<String, String> body = {
        'phone': phone,
      };
      response = await _dio.post(
        '/auth/send-verification-code/',
        data: body,
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPhone(e.response?.data);
    }
    if (response == null) {
      return VerificationCodeResponse(errorResponse!.phone.toString(), null, null);
    } else {
      L.info('verification', 'verification code sent to phone: $phone');
      return VerificationCodeResponse.fromJson(response.data);
    }
  }

  Future<VerificationCodeResponse?> forgotPassword(String phone) async {
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      Map<String, String> body = {
        'phone': phone,
      };
      response = await _dio.post(
        '/auth/forgot-password/request/',
        data: body,
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPhone(e.response?.data);
    }
    if (response == null) {
      return VerificationCodeResponse(errorResponse!.phone.toString(), null, null);
    } else {
      L.info('password', 'password reset code sent to phone: $phone');
      return VerificationCodeResponse.fromJson(response.data);
    }
  }

  Future<VerificationCodeResponse?> passwordReset(String phone, String code, String password) async {
    
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;
    try {
      Map<String, String> body = {
        'phone': phone,
        'code': code,
        'new_password': password,
      };
      response = await _dio.post(
        '/auth/forgot-password/reset/',
        data: body,
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonPassword(e.response?.data);
    }
    if (response == null) {
      return VerificationCodeResponse(errorResponse!.new_password.toString(), null, null);
    } else {
      L.info('password', 'password reset for phone: $phone');
      return VerificationCodeResponse.fromJson(response.data);
    }
  }

  Future<VerificationCodeResponse?> verifyPhoneCode(String phone, String code) async {
    
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse;
    try {
      Map<String, String> body = {
        'phone': phone,
        'code': code,
      };
      response = await _dio.post(
        '/auth/verify/',
        data: body,
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonCode(e.response?.data);
    }
    if (response == null) {
      return VerificationCodeResponse(errorResponse!.phone.toString(), null, null);
    } else {
      L.info('verification', 'code verified for phone: $phone');
      return VerificationCodeResponse.fromJson(response.data);
    }
  }

  Future<VerificationCodeResponse?> verifyAndSign(SignEntity entity) async {
    
    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );
    var response;
    ErrorResponse? errorResponse = null;

    try {
      _dio.options.contentType = Headers.formUrlEncodedContentType;
      Map<String, String> body = {
        'phone': entity.phone,
        'code': entity.code,
        'name': entity.name,
        'surname': entity.surname,
        'password': entity.password,
        'role': entity.role,
        'grade': entity.role == 'parent' ?
         '' : entity.grade,
      };
      response = await _dio.post(
        '/auth/verify-and-create-user/',
        data: body,
      );
    } on DioError catch (e) {
      errorResponse = ErrorResponse.fromJsonNPassword(e.response?.data);
    }
    if (response == null) {
      return VerificationCodeResponse(errorResponse!.password.toString(), null, null);
    } else {
      L.info('registration', 'user successfully registered: ${entity.name} ${entity.surname}');
      return VerificationCodeResponse.fromJson(response.data);
    }
  }
}
