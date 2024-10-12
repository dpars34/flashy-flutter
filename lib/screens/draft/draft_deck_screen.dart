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
import '../../notifiers/profile_notifier.dart';
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