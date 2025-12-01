import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class SignEntity {
  final String phone;
  final String code;
  final String name;
  final String surname;
  final String password;
  final String role;
  late final String grade;

  SignEntity(this.phone,
      this.code,
      this.name,
      this.surname,
      this.password,
      this.role,
      this.grade,);

  Map<String, String> toJson() => {
    'phone': phone,
    'code': code,
    'name': name,
    'surname': surname,
    'password': password,
    'role': role,
    'grade': grade,
  };

}
