import 'dart:async';

import 'package:flashy_flutter/models/category_data.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';

import '../../notifiers/category_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/deck_card.dart';
import '../../widgets/error_modal.dart';
import 'category_deck_screen.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesList = ref.read(categoryProvider);
      if (categoriesList.isEmpty) {
        ref.read(categoryProvider.notifier).fetchCategoryData();
      }
    });
  }

  void _navigateToCategoryDeckScreen(BuildContext context, CategoryData category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDeckScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: categoriesList.isNotEmpty
          ? ListView.builder(
            padding: const EdgeInsets.only(top: 12),
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              final category = categoriesList[index];
              return ListTile(
                leading: Text(
                  category.emoji,
                  style: const TextStyle(
                    fontSize: 20
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                      color: black,
                  ),
                ),

                onTap: () {
                  _navigateToCategoryDeckScreen(context, category);
                },
              );
            },
          )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

void showModal(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorModal(title: title, content: content, context: context);
    },
  );
}
