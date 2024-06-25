import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = ChangeNotifierProvider<LoadingNotifier>((ref) {
  return LoadingNotifier();
});

class LoadingNotifier extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void showLoading(BuildContext context) {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  void hideLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
