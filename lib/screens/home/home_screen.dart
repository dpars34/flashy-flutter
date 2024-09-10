import 'dart:async';

import 'package:flashy_flutter/screens/categories/category_list_screen.dart';
import 'package:flashy_flutter/screens/create/create_deck_screen.dart';
import 'package:flashy_flutter/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/account/account_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/deck_notifier.dart';
import '../../notifiers/category_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/deck_card.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/error_modal.dart';
import '../categories/category_deck_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {

  late ScrollController _scrollController;

  bool isLoaded = false;
  double scrollPosition = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      scrollPosition = _scrollController.position.pixels;
    });
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {

      ref.read(deckProvider.notifier).fetchHomeDeckData();
      ref.read(categoryProvider.notifier).fetchCategoryData();

      setState(() {
        isLoaded = true;
      });
    });
  }

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id, type: 'home',),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckDataList = ref.watch(deckProvider);
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final user = ref.watch(authProvider);

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondary,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: primary,
            ),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/flashy-logo.png',
              height: 40,
            ),
            // LOGO ISN'T CENTERED SO ADDED WIDTH
            const SizedBox(width: 10)
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: primary,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 80),
            Row(
              children: [
                SizedBox(width: 10),
                Image.asset(
                  'assets/flashy-logo.png',
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (user != null) ListTile(
              leading: const Icon(
                Icons.add_circle_outline_outlined,
                color: primary,
              ),
              title: const Text(
                'Create deck',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateDeckScreen()
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.layers_outlined,
                color: primary,
              ),
              title: const Text(
                'Categories',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryListScreen()
                  ),
                );
              },
            ),
            if (user != null) ListTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: primary,
              ),
              title: const Text(
                'My account',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()
                  ),
                );
              },
            ),
            user == null ? ListTile(
              leading: const Icon(
                  Icons.login,
                  color: primary
              ),
              title: const Text(
                'Login',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen()
                  ),
                );
              },
            ) : ListTile(
              leading: const Icon(
                  Icons.logout,
                  color: primary
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () async {
                try {
                  loadingNotifier.showLoading(context);
                  await authNotifier.logout();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  }
                } catch (e) {
                  showModal(context, 'An Error Occurred', 'Please check your internet connection and try again.');
                } finally {
                  loadingNotifier.hideLoading();
                }
              },
            ),
            // Add more items here
          ],
        ),
      ),
      body: isLoaded ?
      SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              children: [
                ...deckDataList.homeDecks.where((category) => category.decks.isNotEmpty).map((category) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${category.category.emoji} ${category.category.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: black,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            child: const Text(
                              'more',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: primary,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDeckScreen(category: category.category),
                                ),
                              ).then((result) {
                                _scrollController.jumpTo(scrollPosition);
                              }) ;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      Column(
                        children: [
                          ...category.decks.map((deckData) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                                onTap: () => _navigateToDeckDetail(context, deckData.id),
                                child: DeckCard(
                                  deckData: deckData,
                                  onUserTap: (int id) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfileScreen(id: id)),
                                    ).then((_) {
                                      ref.read(profileProvider.notifier).clearProfile();
                                    });
                                  },
                                )
                            ),
                          )),
                        ],
                      ),
                      // Text(data.toString())
                      const SizedBox(height: 32.0),
                    ],
                  );
                })
              ]),
        ),
      ) :
      Text('LOADING'),
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