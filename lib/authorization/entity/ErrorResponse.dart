class ErrorResponse {
  List<String> phone = List.empty();
  List<String> message = List.empty();
  List<String> code = List.empty();
  List<String> new_password = List.empty();
  List<String> password = List.empty();

  ErrorResponse({
    required this.phone,
    required this.message,
    required this.code,
    required this.new_password,
    required this.password,
  });

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    phone = json['phone'].cast<String>();
    message = json['message'].cast<String>();
    code = json['code'].cast<String>();
    new_password = json['new_password'].cast<String>();
    password = json['password'].cast<String>();
  }

  ErrorResponse.fromJsonPhone(Map<String, dynamic> json) {
    phone = json['phone'].cast<String>();
  }

  ErrorResponse.fromJsonCode(Map<String, dynamic> json) {
    phone = json['code'].cast<String>();
  }

  ErrorResponse.fromJsonMessage(Map<String, dynamic> json) {
    phone = json['message'].cast<String>();
  }

  ErrorResponse.fromJsonPassword(Map<String, dynamic> json) {
    new_password = json['new_password'].cast<String>();
  }
  ErrorResponse.fromJsonNPassword(Map<String, dynamic> json) {
    password = json['password'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['message'] = message;
    data['code'] = code;
    data['new_password'] = new_password;
    data['password'] = password;
    return data;
  }
}
