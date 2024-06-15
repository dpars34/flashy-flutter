import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/deck_notifier.dart';

import '../widgets/deck_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deckProvider.notifier).fetchDeckData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final deckNotifier = ref.read(deckProvider.notifier);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: !deckDataList.isEmpty ?
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Decks',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: black,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'more',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.0),
                Column(
                  children: [
                    ...deckDataList.map((deckData) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DeckCard(deckData: deckData),
                    )),
                  ],
                )
                // Text(data.toString())
              ],
            ),
          ),
        ) :
        Text('LOADING'),
    );
  }
}