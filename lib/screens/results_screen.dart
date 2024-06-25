import 'package:flashy_flutter/widgets/leaderboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/deck_notifier.dart';
import '../widgets/base_button.dart';
import '../widgets/option_pill.dart';
import '../screens/swipe_screen.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final deckNotifier = ref.read(deckProvider.notifier);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text(''),
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('RESULT'),
        ),
      ),
    );
  }
}