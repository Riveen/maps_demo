import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  String? accessToken = '';
  String? firstName = '';
  String? middleName = '';
  String? secondName = '';
  int? age = null;

  LoginModel(
      {this.accessToken,
      this.firstName,
      this.middleName,
      this.secondName,
      this.age});

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
