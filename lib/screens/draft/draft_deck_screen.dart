import 'dart:async';
import 'dart:convert';

import 'package:flashy_flutter/models/deck_data.dart';
import 'package:flashy_flutter/models/draft_deck_data.dart';
import 'package:flashy_flutter/screens/create/create_deck_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifiers/deck_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/custom_modal.dart';
import '../../widgets/deck_card.dart';
import '../../widgets/error_modal.dart';

class DraftDeckScreen extends ConsumerStatefulWidget {
  const DraftDeckScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DraftDeckScreen> createState() => _DraftDeckScreenState();
}

class _DraftDeckScreenState extends ConsumerState<DraftDeckScreen> {
  late ScrollController _scrollController;
  List<DraftDeckData> decks = [];

  bool _isPageLoading = false;
  bool _isInfinite = false;
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
      _getDrafts();
    });
    // Listen to scroll events
    _scrollController.addListener(() {

    });
  }

  Future _getDrafts () async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('draftDecks');
    if (jsonString != null) {
      List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        decks = jsonData.map((deckJson) => DraftDeckData.fromJson(deckJson)).toList();
      });
    } else {
      setState(() {
        decks = [];
      });
    }
  }

  void _navigateToCreateDeckScreen(BuildContext context, DraftDeckData draftDeckData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDeckScreen(editDeck: draftDeckData.deck, draftId: draftDeckData.id,),
      ),
    ).then((result) {
      _scrollController.jumpTo(scrollPosition);
      _getDrafts();
    });
  }

  void _handleDraftDelete(int deckId, BuildContext context) {
    final loadingNotifier = ref.read(loadingProvider.notifier);

    void doNothing () {}

    Future handleDelete() async {
      try {
        loadingNotifier.showLoading(context);

        final prefs = await SharedPreferences.getInstance();
        final String? jsonString = prefs.getString('draftDecks');
        List<dynamic> jsonData = [];

        if (jsonString != null) jsonData = jsonDecode(jsonString);
        List<DraftDeckData>decks = jsonData.map((deckJson) => DraftDeckData.fromJson(deckJson)).toList();

        int index = decks.indexWhere((deck) => deck.id == deckId);
        if (index != -1) {
          decks.removeAt(index);
        }

        String decksAsJsonString = jsonEncode(decks.map((deck) => deck.toJson()).toList());
        prefs.setString('draftDecks', decksAsJsonString);
        _getDrafts();

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: !_isPageLoading
          ? decks.isEmpty ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1, // 10% of the screen height
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    color: gray2,
                    size: 100,
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "You don't have any drafts!",
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
            ),
          ) : Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                child: const Text(
                  'Draft decks',
                  style: TextStyle(
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
                              onTap: () => _navigateToCreateDeckScreen(context, deckData),
                              child: DeckCard(
                                deckData: deckData.deck,
                                onUserTap: (int id) {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => ProfileScreen(id: id)),
                                  // ).then((_) {
                                  //   ref.read(profileProvider.notifier).clearProfile();
                                  // });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _handleDraftDelete(deckData.id, context),
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