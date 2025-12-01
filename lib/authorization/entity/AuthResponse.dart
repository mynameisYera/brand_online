class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse(
      this.accessToken,
      this.refreshToken,
      );

  AuthResponse.fromJson(Map<String, dynamic> map)
      : accessToken = map['access'],
        refreshToken = map['refresh'];

  AuthResponse.fromJsonAccess(Map<String, dynamic> map, this.refreshToken)
      : accessToken = map['access'];
}
