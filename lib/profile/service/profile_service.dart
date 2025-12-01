import 'dart:async';
import 'package:dio/dio.dart';
import 'package:brand_online/core/loggers/l.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../general/GeneralUtil.dart';
import '../entity/StudentProfile.dart';
import '../entity/WalletTransaction.dart';

class ProfileService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: GeneralUtil.BASE_URL),
  );
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<StudentProfile?> getStudentProfile() async {
    String? token = await _storage.read(key: 'auth_token');
    print(token);

    try {
      final response = await _dio.get(
        '/edu/student-profile/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        L.info('Profile', 'Профиль студента успешно получен');
        L.jsonPretty('Student Profile Response', response.data);
        return StudentProfile.fromJson(response.data);
      } else {
        L.error('Profile', 'Ошибка получения профиля: статус ${response.statusCode}');
        return null;
      }
    } catch (e) {
      L.error('Profile', 'Ошибка при получении профиля студента: $e');
      return null;
    }
  }

  Future<List<WalletTransaction>> getTransactionHistory() async {
    String? token = await _storage.read(key: 'auth_token');

    final Dio _dio = Dio(
      BaseOptions(baseUrl: GeneralUtil.BASE_URL),
    );

    try {
      final response = await _dio.get(
        '/edu/wallet/history/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => WalletTransaction.fromJson(json))
            .toList();
      } else {
        print("Ошибка от сервера: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print('Ошибка при получении истории кошелька: $e');
      return [];
    }
  }


  Future<void> withdrawBalance(int amount) async {
    String? token = await _storage.read(key: 'auth_token');

    final response = await _dio.post(
      '/edu/wallet/withdraw/',
      data: {'amount': amount},
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Сервер қайтарған қате: ${response.statusCode}');
    }
  }
  Future<void> deleteProfile() async {
    String? token = await _storage.read(key: 'auth_token');

    final response = await _dio.delete(
      '/auth/delete-account/',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    L.info('Profile', 'Профиль студента успешно удален');
    L.jsonPretty('Student Profile Deleted Response', response.data);
    if (response.statusCode != 200) {
      throw Exception('Сервер қайтарған қате: ${response.statusCode}');
    }
  }
}
