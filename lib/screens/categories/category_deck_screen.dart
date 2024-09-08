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
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _isInfinite = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Fetch the initial deck data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckDataList = ref.watch(deckProvider);
      int categoryIndex = deckDataList.detailDecks.indexWhere((item) => item.category.id == widget.category.id);
      if (categoryIndex == -1) {
        ref.read(deckProvider.notifier).fetchDecksByCategory(widget.category.id, 10, _currentPage);
      }
    });

    // Listen to scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading && _isInfinite) {
        _fetchMoreDecks();
      }
    });
  }

  Future<void> _fetchMoreDecks() async {
    setState(() {
      _isLoading = true;
    });

    final deckDataList = ref.watch(deckProvider);
    final DecksByCategoryData category = deckDataList.detailDecks.firstWhere((item) => item.category.id == widget.category.id);

    // Fetch more decks based on the current page
    await ref.read(deckProvider.notifier).fetchDecksByCategory(widget.category.id, 10, _currentPage + 1);

    setState(() {
      _currentPage += 1;
      _isLoading = false;

      // Stop infinite scrolling if there are no more pages
      if (category.pagination.currentPage >= category.pagination.lastPage) {
        _isInfinite = false;
      }
    });
  }

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id, type: 'detail'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final List<DeckData> decks;

    int categoryIndex = deckDataList.detailDecks.indexWhere((item) => item.category.id == widget.category.id);
    if (categoryIndex == -1) {
      decks = [];
    } else {
      final DecksByCategoryData category = deckDataList.detailDecks.firstWhere((item) => item.category.id == widget.category.id);
      decks = category.decks;
      if (category.pagination.currentPage >= category.pagination.lastPage) {
        _isInfinite = false;
      }
    }

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text('${widget.category.emoji} ${widget.category.name}'),
      ),
      body: decks.isNotEmpty
          ? Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: decks.length + (_isInfinite ? 1 : 0), // Add 1 for the loading indicator
              itemBuilder: (context, index) {
                if (index == decks.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(), // Loading spinner at the bottom
                    ),
                  );
                }
                final deckData = decks[index];
                return Padding(
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
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      )
          : const Center(child: CircularProgressIndicator()), // Show loading spinner while decks are loading
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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