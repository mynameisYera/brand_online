import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class SignEntity {
  final String phone;
  final String code;
  final String name;
  final String surname;
  final String password;
  final String role;

  SignEntity(this.phone,
      this.code,
      this.name,
      this.surname,
      this.password,
      this.role,
      );

  Map<String, String> toJson() => {
    'phone': phone,
    'code': code,
    'name': name,
    'surname': surname,
    'password': password,
    'role': role,
  };

}
