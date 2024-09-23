import 'dart:math';

import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flashy_flutter/models/highscores_data.dart';
import 'package:flashy_flutter/widgets/leaderboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/answer_data.dart';
import '../../models/deck_data.dart';
import '../../notifiers/auth_notifier.dart';
import '../../notifiers/deck_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../utils/api_exception.dart';
import '../../widgets/base_button.dart';
import '../../widgets/error_modal.dart';
import '../profile/profile_screen.dart';
import 'deck_review_screen.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({
    Key? key,
    required this.deck,
    required this.answers,
    required this.time
  }) : super(key: key);

  final DeckData deck;
  final List<AnswerData> answers;
  final int time;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _highscoreController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _highscoreAnimation;
  late Animation<double> _fadeAnimation;

  String _message = '';
  int correctAnswers = 0;

  bool isNewRecord = false;
  int? newRecordIndex;
  List<HighscoresData> newRecordData = [];
  String? recordType;

  void _handleHighscore () async {
    final user = ref.read(authProvider);

    // IF NO RECORDS
    if (widget.deck.highscores.isEmpty) {
      isNewRecord = true;
      newRecordIndex = 0;
      recordType = 'add';
    }

    // IF LESS THAN 3 RECORDS
    else if (widget.deck.highscores.length < 3) {
      bool newIndexAdded = false;
      widget.deck.highscores.asMap().forEach((index, highscore) {
        if ((widget.time < highscore.time) && !newIndexAdded) {
          newRecordIndex = index;
          newIndexAdded = true;
        }
      });
      if (!newIndexAdded) {
        newRecordIndex = widget.deck.highscores.length;
      }
      isNewRecord = true;
      recordType = 'add-no-delete';
    }

    // IF MORE THAN 3
    else {
      bool newIndexAdded = false;
      widget.deck.highscores.asMap().forEach((index, highscore) {
        if ((widget.time < highscore.time) && !newIndexAdded) {
          isNewRecord = true;
          newRecordIndex = index;
          recordType = 'update';
          newIndexAdded = true;
        }
      });
    }

    HighscoresData newHighscore = HighscoresData(
        id: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deckId: widget.deck.id,
        userId: user!.id,
        time: widget.time,
        user: user,
    );

    newRecordData =  List.from(widget.deck.highscores);

    if (recordType == 'add') {
      newRecordData.add(newHighscore);
    } else if (recordType == 'add-no-delete') {
      newRecordData.insert(newRecordIndex!, newHighscore);
    } else if (recordType == 'update') {
      newRecordData.insert(newRecordIndex!, newHighscore);
      newRecordData.removeLast();
    }

    if (isNewRecord) {
      Confetti.launch(
        context,
        options: const ConfettiOptions(
            particleCount: 100, spread: 70, y: 0.6),
      );

      try {
        await ref.read(deckProvider.notifier).submitHighscore(widget.deck.id, widget.time);
      } catch (e) {
        if (e is ApiException) {
          showModal(context, 'An Error Occurred', 'Please try again');
        } else {
          showModal(context, 'An Error Occurred', 'Please try again');
        }
      }
    }
  }

  void _generateMessage () {
    final user = ref.read(authProvider);

    for (var answer in widget.answers) {
      if (answer.correctAnswer == answer.userAnswer) {
        correctAnswers++;
      }
    }

    String formatTime(int timeInMilliseconds) {
      final int minutes = timeInMilliseconds ~/ 60000;
      final int seconds = (timeInMilliseconds % 60000) ~/ 1000;
      final int milliseconds = (timeInMilliseconds % 1000) ~/ 10;

      final String formattedMinutes = minutes.toString();
      final String formattedSeconds = seconds.toString().padLeft(2, '0');
      final String formattedMilliseconds = milliseconds.toString().padLeft(2, '0');

      return "$formattedMinutes:$formattedSeconds.$formattedMilliseconds";
    }

    String timeTaken = formatTime(widget.time);

    if (correctAnswers == widget.deck.count) {

      if (user != null) {
        _handleHighscore();
      }

      List<String> niceWords = ['Incredible!', 'Wow!', 'Fantastic!', 'Super!', 'Woohoo!'];

      final random = Random();
      String randomWord = niceWords[random.nextInt(niceWords.length)];

      setState(() {
        _message = '$randomWord You got $correctAnswers/${widget.deck.count} answers correct in $timeTaken!';
      });
    } else if (correctAnswers == widget.deck.count - 1 || correctAnswers == widget.deck.count - 2) {
      List<String> niceWords = ['Not bad!', 'Good work!', 'Nice!'];

      final random = Random();
      String randomWord = niceWords[random.nextInt(niceWords.length)];

      setState(() {
        _message = '$randomWord You got $correctAnswers/${widget.deck.count} answers correct in $timeTaken!';
      });
    } else {
      setState(() {
        _message = 'You got $correctAnswers/${widget.deck.count} answers correct in $timeTaken';
      });
    }

    // HANDLE ANIMATIONS
    if (isNewRecord) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _highscoreController.forward();
        }
      });
      _highscoreController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _fadeController.forward();
        }
      });
    } else {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _fadeController.forward();
        }
      });
    }

    _controller.forward();
  }

  void _goBack () {
    Navigator.of(context).pop();
  }

  void _goToReviewScreen () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeckReviewScreen(
        deck: widget.deck,
        answers: widget.answers,
        time: widget.time,
        score: correctAnswers
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_controller);

    _highscoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _highscoreAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_highscoreController);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newRecordData = widget.deck.highscores;
      _generateMessage();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _highscoreController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final deckNotifier = ref.read(deckProvider.notifier);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(widget.deck.name),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1, // 10% of the screen height
                  ),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: black,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (newRecordData.isNotEmpty) SizedBox(height: 24),
                  if (isNewRecord) ScaleTransition(
                    scale: _highscoreAnimation,
                    child: const Text(
                     'That’s a new record!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ScaleTransition(
                    scale: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        newRecordData.isNotEmpty ? LeaderboardCard(
                          highscoresData: newRecordData, highlightIndex: newRecordIndex,
                          onUserTap: (int id) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen(id: id)),
                            ).then((_) {
                              ref.read(profileProvider.notifier).clearProfile();
                            });
                          },
                        ) : Container(
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
                        SizedBox(height: 60),
                        BaseButton(onPressed: _goToReviewScreen, text: 'Review answers', outlined: true,),
                        SizedBox(height: 8),
                        BaseButton(onPressed: _goBack, text: 'Go back')
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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