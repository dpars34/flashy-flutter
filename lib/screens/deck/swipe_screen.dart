import 'dart:async';
import 'package:flashy_flutter/screens/deck/results_screen.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/models/cards_data.dart';
import 'package:flashy_flutter/widgets/swipe_card.dart';
import '../../notifiers/deck_notifier.dart';

import 'package:appinio_swiper/appinio_swiper.dart';


class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({Key? key, required this.title, required this.id}) : super(key: key);

  final String title;
  final int id;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final AppinioSwiperController controller = AppinioSwiperController();
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
        _isLoading = false;
      _startTimer();
    });
  }

  // void _initializeMatchEngine() {
  //   final deckDataList = ref.read(deckProvider);
  //
  //   // Ensure the deck exists
  //   final deck = deckDataList.firstWhere((deck) => deck.id == widget.id, orElse: () {
  //     throw Exception('Deck with id ${widget.id} not found');
  //   });
  //
  //   final List<CardsData>? allCards = deck.cards;
  //   _totalCount = allCards?.length ?? 0;
  //
  //   final swipeItems = allCards?.map((item) => SwipeItem(
  //     content: SwipeCard(item: item),
  //     likeAction: () {
  //       setState(() {
  //         _swipeCounter++;
  //       });
  //     },
  //     nopeAction: () {
  //       setState(() {
  //         _swipeCounter++;
  //       });
  //     },
  //   )).toList();
  //
  //   setState(() {
  //     _matchEngine = MatchEngine(swipeItems: swipeItems);
  //     _isLoading = false;
  //   });
  // }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        print('The card was swiped to the : ${activity.direction}');
        print('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        print('A ${activity.direction.name} swipe was undone.');
        print('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        print('A swipe was cancelled');
        break;
      case DrivenActivity():
        print('Driven Activity');
        break;
    }
  }

  void _onEnd () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultsScreen(id: 1,)),
    );
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
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double width = constraints.maxWidth;
                return SizedBox(
                  width: width,
                  height: width,
                  child: AppinioSwiper(
                    invertAngleOnBottomDrag: true,
                    backgroundCardCount: 0,
                    swipeOptions: const SwipeOptions.all(),
                    controller: controller,
                    onSwipeEnd: _swipeEnd,
                    onEnd: _onEnd,
                    cardCount: deck.cards!.length,
                    threshold: 25,
                    cardBuilder: (BuildContext context, int index) {
                      return SwipeCard(item: deck.cards![index]);
                    },
                  ),
                );
              },
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