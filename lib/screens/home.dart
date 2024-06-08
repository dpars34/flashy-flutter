import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/api_helper.dart';
import 'package:flashy_flutter/utils/colors.dart';

import '../classes/deck_data.dart';
import '../components/deck_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DATA
  late List<DeckData> deckDataList;

  bool loaded = false;


  final DeckData dummyDeckData = DeckData(
    id: 1,
    createdAt: DateTime.parse('2024-06-01T07:14:12.000000Z'),
    updatedAt: DateTime.parse('2024-06-01T07:14:12.000000Z'),
    creatorUserId: 10,
    name: 'Dummy Deck',
    description: 'This is a dummy description.',
    categories: ['math'],
    leftOption: 'false',
    rightOption: 'true',
    count: 10,
    creatorUserName: 'Mr Test Person',
  );

  final ApiHelper apiHelper = ApiHelper();

  Future fetchData() async {
    List<dynamic> jsonData = await apiHelper.get('/decks');
    deckDataList = jsonData.map((json) => DeckData.fromJson(json)).toList();

    setState(() {
      loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: loaded ?
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