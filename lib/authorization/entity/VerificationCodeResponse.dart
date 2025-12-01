class VerificationCodeResponse {
  final String? message;
  final String? refresh;
  final String? access;

  VerificationCodeResponse(this.message, this.refresh, this.access);

  factory VerificationCodeResponse.fromJson(Map<String, dynamic> map) {
    return VerificationCodeResponse(
      map['message'] as String?,
      map['refresh'] as String?,
      map['access'] as String?,
    );
  }
}