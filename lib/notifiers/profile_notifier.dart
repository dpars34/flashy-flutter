import 'dart:io';

import 'package:flashy_flutter/models/login_data.dart';
import 'package:flashy_flutter/models/user_data.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashy_flutter/utils/api_helper.dart';

import '../models/profile_data.dart';
import '../models/user_data.dart';

class ProfileNotifier extends StateNotifier<ProfileData?> {
  final ApiHelper apiHelper = ApiHelper();

  ProfileNotifier() : super(null);

  Future loadProfile(int id) async {
    try {
      var response = await apiHelper.get('/profile/$id');
      state = ProfileData.fromJson(response);

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  void clearProfile () {
    state = null;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileData?>((ref) {
  return ProfileNotifier();
});
