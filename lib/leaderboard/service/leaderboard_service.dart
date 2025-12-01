import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../general/GeneralUtil.dart';
import '../entity/LeaderboardResponse.dart';

class LeaderboardService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: GeneralUtil.BASE_URL),
  );
  final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<LeaderboardResponse?> getLeaderBoardByType(int index) async {
    String? token = await _storage.read(key: 'auth_token');

    try {
      final response = await _dio.get(
         (index == 0) ? '/edu/leaderboard/weekly/' :
         (index == 1) ? '/edu/leaderboard/monthly/' :
         '/edu/leaderboard/'
        ,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return LeaderboardResponse.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print("Ошибка при получении лидерборда: $e");
      return null;
    }
  }
}