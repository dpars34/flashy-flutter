import 'dart:async';
import 'package:flashy_flutter/screens/deck/results_screen.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/models/cards_data.dart';
import 'package:flashy_flutter/widgets/swipe_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../notifiers/deck_notifier.dart';
import '../../widgets/swipe_tag.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({Key? key, required this.title, required this.id}) : super(key: key);

  final String title;
  final int id;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  late MatchEngine _matchEngine;
  bool _isLoading = true;
  int _swipeCounter = 1;
  int _totalCount = 0;

  // Timer-related variables
  late Timer _timer;
  int _elapsedMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMatchEngine();
      _startTimer();
    });
  }

  void _initializeMatchEngine() {
    final deckDataList = ref.read(deckProvider);

    // Ensure the deck exists
    final deck = deckDataList.firstWhere((deck) => deck.id == widget.id, orElse: () {
      throw Exception('Deck with id ${widget.id} not found');
    });

    final List<CardsData>? allCards = deck.cards;
    _totalCount = allCards?.length ?? 0;

    final swipeItems = allCards?.map((item) => SwipeItem(
      content: SwipeCard(item: item),
      likeAction: () {
        setState(() {
          _swipeCounter++;
        });
      },
      nopeAction: () {
        setState(() {
          _swipeCounter++;
        });
      },
    )).toList();

    setState(() {
      _matchEngine = MatchEngine(swipeItems: swipeItems);
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        _elapsedMilliseconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int minutes = (milliseconds ~/ 60000);
    int seconds = (milliseconds ~/ 1000) % 60;
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutes:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);

    // Ensure the deck exists
    final deck = deckDataList.firstWhere((deck) => deck.id == widget.id, orElse: () {
      throw Exception('Deck with id ${widget.id} not found');
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                OptionPill(color: 'red', text: deck.leftOption, large: true,),
                const Spacer(),
                const Icon(Icons.access_time, size: 18, color: black),
                const SizedBox(width: 4),
                Container(
                  width: 60,
                  child: Text(
                    _formatTime(_elapsedMilliseconds),
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    ),
                  ),
                ),
                const Spacer(),
                OptionPill(color: 'green', text: deck.rightOption, large: true,)
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  return SwipeCard(item: deck.cards![index]);
                },
                onStackFinished: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ResultsScreen(id: 1,)),
                  );
                },
                upSwipeAllowed: false,
                fillSpace: false,
                likeTag: SwipeTag(color: 'green', text: deck.rightOption,),
                nopeTag: SwipeTag(color: 'red', text: deck.leftOption,),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Spacer(),
                Text(
                  '$_swipeCounter / $_totalCount',
                  style: const TextStyle(
                    color: gray,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}