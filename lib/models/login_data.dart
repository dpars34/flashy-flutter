import 'package:flashy_flutter/models/user_data.dart';

class LoginData {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginData({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token ': accessToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}