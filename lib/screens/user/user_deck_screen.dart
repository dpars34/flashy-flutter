import 'dart:async';

import 'package:flashy_flutter/models/deck_data.dart';
import 'package:flashy_flutter/models/decks_by_category_data.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';

import '../../models/category_data.dart';
import '../../notifiers/deck_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/deck_card.dart';
import '../../widgets/error_modal.dart';

class UserDeckScreen extends ConsumerStatefulWidget {
  const UserDeckScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<UserDeckScreen> createState() => _UserDeckScreenState();
}

class _UserDeckScreenState extends ConsumerState<UserDeckScreen> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _isInfinite = true;
  int _currentPage = 1;
  double scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      scrollPosition = _scrollController.position.pixels;
    });

    // Fetch the initial deck data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckDataList = ref.watch(deckProvider);
      if (deckDataList.userDecks == null) {
        ref.read(deckProvider.notifier).fetchUserDecks(10, _currentPage);
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

    // Fetch more decks based on the current page
    await ref.read(deckProvider.notifier).fetchUserDecks(10, _currentPage + 1);

    setState(() {
      _currentPage += 1;
      _isLoading = false;

      // Stop infinite scrolling if there are no more pages
      if (deckDataList.userDecks!.pagination.currentPage >= deckDataList.userDecks!.pagination.lastPage) {
        _isInfinite = false;
      }
    });
  }

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id, type: 'user'),
      ),
    ).then((result) {
      _scrollController.jumpTo(scrollPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final List<DeckData> decks;

    if (deckDataList.userDecks == null) {
      decks = [];
    } else {
      decks = deckDataList.userDecks!.decks;
      if (deckDataList.userDecks!.pagination.currentPage >= deckDataList.userDecks!.pagination.lastPage) {
        _isInfinite = false;
      }
    }

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text('My decks'),
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