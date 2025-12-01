import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../general/GeneralUtil.dart';
import '../entity/News.dart';
import '../entity/NewsDetailed.dart';

class NewsService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: GeneralUtil.BASE_URL),
  );
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // /edu/notifications/
  Future<List<Notification>> getNotifications() async {
    String? token = await _storage.read(key: 'auth_token');

    try {
      final response = await _dio.get(
        '/edu/notifications/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => Notification.fromJson(json))
            .toList();
      } else {
        print(response);
        return [];
      }
    } catch (e) {
      print("Ошибка при получении уведомлении: $e");
      return [];
    }
  }

  Future<List<News>> getNews() async {
    String? token = await _storage.read(key: 'auth_token');

    try {
      final response = await _dio.get(
        '/edu/news/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => News.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Ошибка при получении новостей: $e");
      return [];
    }
  }

  Future<NewsDetailed?> getNewsDetail(int id) async {
    String? token = await _storage.read(key: 'auth_token');

    try {
      final response = await _dio.get(
        '/edu/news/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return NewsDetailed.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('Ошибка при получении детали новости: $e');
      return null;
    }
  }

}