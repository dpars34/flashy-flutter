import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String email;

  User({required this.id, required this.email});
}

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);

  void login(String id, String email) {
    state = User(id: id, email: email);
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});