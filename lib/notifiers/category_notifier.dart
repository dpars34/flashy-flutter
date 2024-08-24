import 'package:flashy_flutter/models/category_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/utils/api_helper.dart';

class CategoryNotifier extends StateNotifier<List<CategoryData>> {
  CategoryNotifier(this.ref) : super([]);

  final Ref ref; // Reference to access other providers
  final ApiHelper apiHelper = ApiHelper();

  Future<void> fetchCategoryData() async {
    List<dynamic> jsonData = await apiHelper.get('/categories');
    state = jsonData.map((json) => CategoryData.fromJson(json)).toList();
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<CategoryData>>((ref) {
  return CategoryNotifier(ref);
});
