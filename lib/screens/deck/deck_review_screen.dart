import 'package:flashy_flutter/widgets/leaderboard_card.dart';
import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../models/answer_data.dart';
import '../../models/deck_data.dart';
import '../../widgets/base_button.dart';

class DeckReviewScreen extends ConsumerStatefulWidget {
  const DeckReviewScreen({
    Key? key,
    required this.deck,
    required this.answers,
    required this.time,
    required this.score,
  }) : super(key: key);

  final DeckData deck;
  final List<AnswerData> answers;
  final int time;
  final int score;

  @override
  ConsumerState<DeckReviewScreen> createState() => _DeckReviewScreenState();
}

class _DeckReviewScreenState extends ConsumerState<DeckReviewScreen> {

  String formatTime(int timeInMilliseconds) {
    final int minutes = timeInMilliseconds ~/ 60000;
    final int seconds = (timeInMilliseconds % 60000) ~/ 1000;
    final int milliseconds = (timeInMilliseconds % 1000) ~/ 10;

    final String formattedMinutes = minutes.toString();
    final String formattedSeconds = seconds.toString().padLeft(2, '0');
    final String formattedMilliseconds = milliseconds.toString().padLeft(2, '0');

    return "$formattedMinutes:$formattedSeconds.$formattedMilliseconds";
  }

  void _goBack () {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(widget.deck.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Review',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: black,
                  fontSize: 20,
                ),
              ),
              Text(
                'Score: ${widget.score}/${widget.deck.count}',
                style: const TextStyle(
                    color: gray,
                    fontSize: 14
                ),
              ),
              Text(
                'Time: ${formatTime(widget.time)}',
                style: const TextStyle(
                    color: gray,
                    fontSize: 14
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: widget.answers.asMap().entries.map((entry) {
                  int index = entry.key;
                  var answer = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              color: black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(width: 8),
                          answer.userAnswer == answer.correctAnswer ? const Icon(
                            Icons.check,
                            color: green,
                          ) : const Icon(
                            Icons.close,
                            color: red,
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        answer.card.text,
                        style: const TextStyle(
                          color: gray,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (answer.card.note != null && answer.card.note != '') Text(
                        'Note: ${answer.card.note}',
                        style: const TextStyle(
                            color: gray,
                            fontSize: 12
                        ),
                      ),
                      if (answer.card.note != null && answer.card.note != '') const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Your answer: ',
                            style: TextStyle(
                                color: gray,
                                fontSize: 14,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          const SizedBox(width: 8),
                          answer.userAnswer == 'left' ? OptionPill(
                              color: 'red',
                              text: widget.deck.leftOption,
                          ) : OptionPill(
                            color: 'green',
                            text: widget.deck.rightOption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8,),
                      Row(
                        children: [
                          const Text(
                            'Correct answer: ',
                            style: TextStyle(
                                color: gray,
                                fontSize: 14,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          const SizedBox(width: 8),
                          answer.correctAnswer == 'left' ? OptionPill(
                            color: 'red',
                            text: widget.deck.leftOption,
                          ) : OptionPill(
                            color: 'green',
                            text: widget.deck.rightOption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // BaseButton(onPressed: _goBack, text: 'Go back', outlined: true,),
              // const SizedBox(height: 100),
            ],
          ),
        ),
      )
    );
  }
}
