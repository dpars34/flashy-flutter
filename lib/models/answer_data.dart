import 'package:flashy_flutter/models/cards_data.dart';

class AnswerData {
  final CardsData card;
  final String userAnswer;
  final String correctAnswer;

  AnswerData({
    required this.card,
    required this.userAnswer,
    required this.correctAnswer,
  });
}