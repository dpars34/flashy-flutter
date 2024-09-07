import 'package:flashy_flutter/models/deck_data.dart';
import 'package:flashy_flutter/widgets/leaderboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/deck_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../utils/api_exception.dart';
import '../../widgets/base_button.dart';
import '../../widgets/error_modal.dart';
import '../../widgets/option_pill.dart';
import '../profile/profile_screen.dart';
import './swipe_screen.dart';

class DeckDetailScreen extends ConsumerStatefulWidget {
  const DeckDetailScreen({Key? key, required this.id, required this.type}) : super(key: key);

  final int id;
  final String type;

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {

  bool likeProcessing = false;

  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.type == 'home') {
        final deck = ref.read(deckProvider).homeDecks
            .expand((categoryDeck) => categoryDeck.decks)
            .firstWhere((deck) => deck.id == widget.id);

        if (deck?.cards == null) {
          ref.read(deckProvider.notifier).fetchDeckDetails(widget.id);
        }
      } else if (widget.type == 'detail') {
        final deck = ref.read(deckProvider).detailDecks
            .expand((categoryDeck) => categoryDeck.decks)
            .firstWhere((deck) => deck.id == widget.id);

        if (deck?.cards == null) {
          ref.read(deckProvider.notifier).fetchDeckDetails(widget.id);
        }
      }
    });
  }

  void _handleLikeClick (int deckId) async {
    final user = ref.watch(authProvider);

    if (user == null) {
      showModal(
        context,
        'Register to like this deck!',
        "By registering, you'll be able to like decks, get on the leaderboard and create your own decks!"
      );
      return;
    }

    if (likeProcessing) return;
    try {
      likeProcessing = true;
      await ref.read(deckProvider.notifier).likeDeck(deckId);
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (e is ApiException) {
        showModal(context, 'An Error Occurred', 'Please try again');
      } else {
        showModal(context, 'An Error Occurred', 'Please try again');
      }
    } finally {
      likeProcessing = false;
    }
  }

  void _handleUnlikeClick (int deckId) async {
    if (likeProcessing) return;
    try {
      likeProcessing = true;
      await ref.read(deckProvider.notifier).unlikeDeck(deckId);
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (e is ApiException) {
        showModal(context, 'An Error Occurred', 'Please try again');
      } else {
        showModal(context, 'An Error Occurred', 'Please try again');
      }
    } finally {
      likeProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final deckNotifier = ref.read(deckProvider.notifier);
    final user = ref.watch(authProvider);

    late DeckData deck;

    if (widget.type == 'home') {
      deck = ref.read(deckProvider).homeDecks
          .expand((categoryDeck) => categoryDeck.decks)
          .firstWhere((deck) => deck.id == widget.id);
    } else if (widget.type == 'detail') {
      deck = ref.read(deckProvider).detailDecks
          .expand((categoryDeck) => categoryDeck.decks)
          .firstWhere((deck) => deck.id == widget.id);
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                deck.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              if (deck.description != '') Text(
                deck.description,
                style: const TextStyle(
                  color: gray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen(id: deck.id)),
                      ).then((_) {
                        ref.read(profileProvider.notifier).clearProfile();
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (deck.creator.profileImage != null) ? CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(deck.creator.profileImage!),
                          onBackgroundImageError: (exception, stackTrace) {
                            print('Error loading image: $exception');
                          },
                        ) : const Icon(
                            Icons.account_circle,
                            size: 20,
                            color: gray2
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deck.creator.name,
                          style: const TextStyle(
                            color: gray,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        size: 14,
                        color: gray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deck.likedUsers.length.toString(),
                        style: const TextStyle(
                          color: gray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OptionPill(color: 'red', text: deck.leftOption),
                      const SizedBox(width: 6),
                      OptionPill(color: 'green', text: deck.rightOption)
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                  children: [
                    if (deck.highscores!.isNotEmpty) LeaderboardCard(
                      highscoresData: deck.highscores ?? [], highlightIndex: null,
                      onUserTap: (int id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen(id: id)),
                        ).then((_) {
                          ref.read(profileProvider.notifier).clearProfile();
                        });
                      },
                    ),
                    if (deck.highscores!.isEmpty) Container(
                      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: white,
                      ),
                      child: const Text(
                        "There doesn't seem to be anyone on the leaderboard!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gray,
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ),
                    const SizedBox(height: 30),
                    deck.likedUsers.contains(user?.id) ? BaseButton(
                      text: 'Deck liked',
                      color: green,
                      onPressed: () => _handleUnlikeClick(deck.id),
                    ) : BaseButton(
                      text: 'Like deck',
                      color: green,
                      outlined: true,
                      onPressed: () => _handleLikeClick(deck.id),
                    ),
                    const SizedBox(height: 8),
                    BaseButton(
                      text: 'Start',
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SwipeScreen(
                            deck: deck,
                          )),
                        ),
                      },
                    ),
                  ],
                )
            ],
          ),
        ),
      )
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