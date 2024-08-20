import 'package:flashy_flutter/widgets/leaderboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/deck_notifier.dart';
import '../../utils/api_exception.dart';
import '../../widgets/base_button.dart';
import '../../widgets/error_modal.dart';
import '../../widgets/option_pill.dart';
import './swipe_screen.dart';

class DeckDetailScreen extends ConsumerStatefulWidget {
  const DeckDetailScreen({Key? key, required this.id}) : super(key: key);

  final int id;

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
      final deck = ref.read(deckProvider).firstWhere((deck) => deck.id == widget.id);
      if (deck?.cards == null) {
        ref.read(deckProvider.notifier).fetchDeckDetails(widget.id);
      }
    });
  }

  void _handleLikeClick (int deckId) async {
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

    final deck = deckDataList.firstWhere((deck) => deck.id == widget.id);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body: deckDataList.isNotEmpty ?
      SingleChildScrollView(
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
              Text(
                deck.description,
                style: const TextStyle(
                  color: gray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage('https://placehold.jp/150x150.png'),
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Error loading image: $exception');
                    },
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
                  const SizedBox(width: 6),
                  Row(
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
                    if (deck.highscores!.isNotEmpty) LeaderboardCard(highscoresData: deck.highscores ?? []),
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
                          MaterialPageRoute(builder: (context) => SwipeScreen(id: deck.id, title: deck.name)),
                        ),
                      },
                    ),
                  ],
                )
            ],
          ),
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