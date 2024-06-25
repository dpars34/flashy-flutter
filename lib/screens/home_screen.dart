import 'package:flashy_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck_detail_screen.dart';

import '../notifiers/auth_notifier.dart';
import '../notifiers/deck_notifier.dart';
import '../widgets/deck_card.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/loading_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id),
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
            // ListTile(
            //   leading: const Icon(
            //     Icons.home,
            //     color: black,
            //   ),
            //   title: const Text(
            //     'Home',
            //     style: TextStyle(
            //       color: black,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     // Navigate to home
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(
            //     Icons.settings,
            //     color: black
            //   ),
            //   title: const Text(
            //     'Settings',
            //     style: TextStyle(
            //       color: black,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     // Navigate to settings
            //   },
            // ),
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
      body: deckDataList.isNotEmpty ?
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
                      child: InkWell(
                        onTap: () => _navigateToDeckDetail(context, deckData.id),
                        child: DeckCard(deckData: deckData)
                      ),
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