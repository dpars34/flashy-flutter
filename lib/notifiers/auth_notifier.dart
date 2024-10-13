import 'dart:io';

import 'package:flashy_flutter/models/login_data.dart';
import 'package:flashy_flutter/models/user_data.dart';
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
      try {
        Map<String, dynamic> jsonData = await apiHelper.get('/user');
        User userData = User.fromJson(jsonData);
        state = userData;
      } catch (e) {
        // IF ERROR THEN IGNORE
        print(e);
      }
      print(token);
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

  Future<Map<String, dynamic>> validate(String email, String password, String passwordConfirmation, String userName, String bio, File? image) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'name': userName,
        'bio': bio,
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/register-confirmation', body, file: image);
      return response;

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> register(String email, String password, String passwordConfirmation, String userName, String bio, File? image) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'name': userName,
        'bio': bio
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/register', body, file: image);

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> validateEdit(String email, String userName, String bio, File? image, bool updateImage) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'name': userName,
        'updateImage': updateImage,
        'bio': bio
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/user-edit-confirmation', body, file: image);
      return response;

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> edit(String email, String userName, String bio, File? image, bool updateImage) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'name': userName,
        'updateImage': updateImage,
        'bio': bio
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/user-edit', body, file: image);
      _loadUser();

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> validateOldPassword(String oldPassword) async {
    try {
      Map<String, dynamic> body = {
        'old_password': oldPassword,
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/validate-password', body);
      return response;

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> checkPassword(String oldPassword) async {
    try {
      Map<String, dynamic> body = {
        'old_password': oldPassword,
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/check-password', body);
      return response;

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      Map<String, dynamic> body = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/update-password', body);

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> sendFcmToken(String token) async {
    try {
      Map<String, dynamic> body = {
        'fcm_token': token,
      };

      var response = await apiHelper.post('/update-fcm-token', body);

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      Map<String, dynamic> body = {
        'password': password,
      };

      // Call post method with optional file parameter
      var response = await apiHelper.post('/delete-account', body);

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
