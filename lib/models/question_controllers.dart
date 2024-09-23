import 'package:flutter/material.dart';

class QuestionControllers {
  final TextEditingController questionController;
  final TextEditingController noteController;
  final TextEditingController answerController;
  final int? cardId;

  QuestionControllers({
    required this.questionController,
    required this.noteController,
    required this.answerController,
    required this.cardId,
  });
}