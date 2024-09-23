import 'dart:async';

import 'package:flashy_flutter/models/deck_data.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';

import '../../notifiers/deck_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/custom_modal.dart';
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
  bool _isPageLoading = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final deckDataList = ref.watch(deckProvider);
      if (deckDataList.userDecks == null) {
        try {
          setState(() {
            _isPageLoading = true;
          });
          ref.read(deckProvider.notifier).fetchUserDecks(10, _currentPage, false);
        } catch (e) {
          if (!mounted) return;
          showModal(context, 'An Error Occurred', 'Please try again');
        } finally {
          setState(() {
            _isPageLoading = false;
          });
        }
      } else {
        _currentPage = deckDataList.userDecks!.pagination.currentPage;
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
    await ref.read(deckProvider.notifier).fetchUserDecks(10, _currentPage + 1, false);

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

  void _handleDeckDelete(int deckId, BuildContext context) {
    final loadingNotifier = ref.read(loadingProvider.notifier);

    void doNothing () {}

    Future handleDelete() async {
      try {
        loadingNotifier.showLoading(context);
        await ref.read(deckProvider.notifier).deleteDeck(deckId);
        showModal(context, 'Delete deck', 'Deck has been successfully deleted');
      } catch (e) {
        showModal(context, 'An Error Occurred', 'Please try logging in again');
      } finally {
        loadingNotifier.hideLoading();
      }
    }

    showDeleteModal(
      context,
      'Delete deck',
      'Are you sure you want to delete this deck?',
      'Delete',
      'Cancel',
      handleDelete,
      doNothing
    );
  }

  Future _refreshPage() async {
    try {
      setState(() {
        _isPageLoading = true;
        _currentPage = 1;
        _isInfinite = true;
      });
      ref.read(deckProvider.notifier).fetchUserDecks(10, _currentPage, true);
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
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: !_isPageLoading
          ? RefreshIndicator(
        onRefresh: _refreshPage,
            child: decks.isEmpty ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1, // 10% of the screen height
                  ),
                  const Icon(
                    Icons.person,
                    color: gray2,
                    size: 100,
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      textAlign: TextAlign.center,
                      "You haven't created any decks yet! You can create your own decks by going to 'Create deck' from the menu",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: gray,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ) : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  child: const Text(
                    'My decks',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: black,
                      fontSize: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 24, left: 24, right: 8, bottom: 24),
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
                        child: Row(
                          children: [
                            Expanded(
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
                            ),
                            InkWell(
                              onTap: () => _handleDeckDelete(deckData.id, context),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.delete,
                                  color: gray,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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

void showDeleteModal(BuildContext context, String title, String content, String button1Text, String button2Text, VoidCallback button1Callback, VoidCallback button2Callback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: title,
        content: content,
        button1Text: button1Text,
        button2Text: button2Text,
        button1Callback: button1Callback,
        button2Callback: button2Callback,
      );
    },
  );
}

void showModal(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorModal(title: title, content: content, context: context);
    },
  );
}