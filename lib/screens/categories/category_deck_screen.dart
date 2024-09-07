import 'dart:async';

import 'package:flashy_flutter/models/deck_data.dart';
import 'package:flashy_flutter/models/decks_by_category_data.dart';
import 'package:flashy_flutter/screens/categories/category_list_screen.dart';
import 'package:flashy_flutter/screens/create/create_deck_screen.dart';
import 'package:flashy_flutter/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/account/account_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';

import '../../models/category_data.dart';
import '../../notifiers/auth_notifier.dart';
import '../../notifiers/deck_notifier.dart';
import '../../notifiers/category_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/deck_card.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/error_modal.dart';

class CategoryDeckScreen extends ConsumerStatefulWidget {
  const CategoryDeckScreen({
    Key? key,
    required this.category
  }) : super(key: key);

  final CategoryData category;

  @override
  ConsumerState<CategoryDeckScreen> createState() => _CategoryDeckScreenState();
}

class _CategoryDeckScreenState extends ConsumerState<CategoryDeckScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckDataList = ref.watch(deckProvider);
      int categoryIndex = deckDataList.detailDecks.indexWhere((item) => item.category.id == widget.category.id);
      if (categoryIndex == -1) {
        ref.read(deckProvider.notifier).fetchDecksByCategory(widget.category.id, 10, 1);
      }
    });
  }

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id, type: 'detail',),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final user = ref.watch(authProvider);

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final List<DeckData> decks;

    int categoryIndex = deckDataList.detailDecks.indexWhere((item) => item.category.id == widget.category.id);
    if (categoryIndex == -1) {
      decks = [];
    } else {
      final DecksByCategoryData category = deckDataList.detailDecks.firstWhere((item) => item.category.id == widget.category.id);
      decks = category.decks;
    }

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: decks.isNotEmpty ?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.category.emoji} ${widget.category.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18.0),
                Column(
                  children: [
                    ...decks.map((deckData) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                          onTap: () => _navigateToDeckDetail(context, deckData.id),
                          child: DeckCard(
                            deckData: deckData,
                            onUserTap: (int id) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfileScreen(id: id)),
                              ).then((_) {
                                ref.read(profileProvider.notifier).clearProfile();
                              });
                            },
                          )
                      ),
                    )),
                  ],
                ),
                // Text(data.toString())
                const SizedBox(height: 32.0),
              ]),
        ),
      ) :
      Text('LOADING'),
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