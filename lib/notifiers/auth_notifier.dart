import 'package:flashy_flutter/models/login_data.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashy_flutter/utils/api_helper.dart';

import '../models/user_data.dart';

class AuthNotifier extends StateNotifier<User?> {
  final ApiHelper apiHelper = ApiHelper();

  AuthNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      // TODO
      // GET USER DATA!!!
      // final userData = jsonDecode(token);
      // state = User(id: userData['id'], email: userData['email']);
    }
  }

  Future<void> login(String email, String password) async {
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    try {
      Map<String, dynamic> jsonData = await apiHelper.post('/login', body);
      LoginData loginData = LoginData.fromJson(jsonData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', '${loginData.tokenType} ${loginData.accessToken}');
      state = loginData.user;

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
