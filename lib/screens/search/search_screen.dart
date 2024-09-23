import 'dart:async';

import 'package:flashy_flutter/models/deck_data.dart';
import 'package:flashy_flutter/widgets/flashy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';

import '../../notifiers/deck_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/deck_card.dart';
import '../../widgets/error_modal.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchQueryController;

  bool _isLoading = false;
  bool _isPageLoading = false;
  bool _isInfinite = true;
  bool _isSearched = false;
  int _currentPage = 1;
  double scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchQueryController = TextEditingController();
    _scrollController.addListener(() {
      scrollPosition = _scrollController.position.pixels;
    });

    // Fetch the initial deck data
    WidgetsBinding.instance.addPostFrameCallback((_) async {

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
    await ref.read(deckProvider.notifier).fetchSearchDecks(_searchQueryController.text, 10, _currentPage + 1, false);

    setState(() {
      _currentPage += 1;
      _isLoading = false;

      // Stop infinite scrolling if there are no more pages
      if (deckDataList.searchDecks!.pagination.currentPage >= deckDataList.searchDecks!.pagination.lastPage) {
        _isInfinite = false;
      }
    });
  }

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id, type: 'search'),
      ),
    ).then((result) {
      _scrollController.jumpTo(scrollPosition);
    });
  }

  Future _searchForDecks() async {
    try {
      setState(() {
        _isPageLoading = true;
        _currentPage = 1;
        _isInfinite = true;
        _isSearched = true;
      });
      await ref.read(deckProvider.notifier).fetchSearchDecks(_searchQueryController.text, 10, _currentPage, true);
    } catch (e) {
      if (!mounted) return;
      showModal(context, 'An Error Occurred', 'Please try again');
    } finally {
      setState(() {
        _isPageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final List<DeckData> decks;

    if (deckDataList.searchDecks == null) {
      decks = [];
    } else {
      decks = deckDataList.searchDecks!.decks;
      if (deckDataList.searchDecks!.pagination.currentPage >= deckDataList.searchDecks!.pagination.lastPage) {
        _isInfinite = false;
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 0),
                  child: FlashySearchBar(
                      controller: _searchQueryController,
                      hintText: 'Search for a deck...',
                      onSubmit: _searchForDecks,
                  ),
                ),
                Expanded(
                  child: !_isPageLoading ? decks.isEmpty
                      ? Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1, // 10% of the screen height
                            ),
                            const Icon(
                              Icons.search,
                              color: gray2,
                              size: 100,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSearched ? 'No decks could be found! :(' : 'Go on, search for a deck!',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: gray,
                                fontSize: 16,
                              ),
                            )
                          ],
                        )
                      )
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
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
                  ) : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
      )
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