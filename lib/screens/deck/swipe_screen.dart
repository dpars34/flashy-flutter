import 'dart:async';
import 'package:flashy_flutter/models/answer_data.dart';
import 'package:flashy_flutter/screens/deck/results_screen.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/models/cards_data.dart';
import 'package:flashy_flutter/widgets/swipe_card.dart';
import '../../models/deck_data.dart';
import '../../notifiers/deck_notifier.dart';

import 'package:appinio_swiper/appinio_swiper.dart';


class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({Key? key, required this.deck}) : super(key: key);

  final DeckData deck;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final AppinioSwiperController controller = AppinioSwiperController();

  bool _isLoading = true;
  int _swipeCounter = 1;
  int _totalCount = 0;
  List<AnswerData> _answers = [];

  // Timer-related variables
  late Timer _timer;
  int _elapsedMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _totalCount = widget.deck.count!;
        _isLoading = false;
      _startTimer();

      Future.delayed(const Duration(seconds: 3)).then((_) {
        if (_swipeCounter == 1) {
          _shakeCard();
        }
      });
    });
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        _swipeCounter++;
        print('The card was swiped to the : ${activity.direction}');
        print('previous index: $previousIndex, target index: $targetIndex');
        _answers.add(AnswerData(
            card: widget.deck.cards![previousIndex],
            userAnswer: activity.direction == AxisDirection.left ? 'left' : 'right',
            correctAnswer: widget.deck.cards![previousIndex].answer,
        ));
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
      MaterialPageRoute(builder: (context) => ResultsScreen(
        deck: widget.deck,
        answers: _answers,
        time: _elapsedMilliseconds,
      )),
    );
  }

  Future<void> _shakeCard() async {
    const double distance = 30;
    // We can animate back and forth by chaining different animations.
    await controller.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await controller.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    // We need to animate back to the center because `animateTo` does not center
    // the card for us.
    await controller.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
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
    int hundredths = (milliseconds ~/ 10) % 100;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredthsStr = hundredths.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr.$hundredthsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(widget.deck.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: controller.swipeLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 100
                    ),
                    child: OptionPill(color: 'yellow', text: widget.deck.leftOption, large: true,),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 18, color: black),
                const SizedBox(width: 4),
                Container(
                  width: 80,
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
                GestureDetector(
                  onTap: controller.swipeRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 100
                    ),
                    child: OptionPill(color: 'purple', text: widget.deck.rightOption, large: true,),
                  ),
                ),
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
                    swipeOptions: const SwipeOptions.symmetric(horizontal: true),
                    controller: controller,
                    onSwipeEnd: _swipeEnd,
                    onEnd: _onEnd,
                    cardCount: widget.deck.cards!.length,
                    threshold: 25,
                    cardBuilder: (BuildContext context, int index) {
                      return SwipeCard(item: widget.deck.cards![index]);
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