import 'dart:async';

import 'package:flashy_flutter/screens/categories/category_list_screen.dart';
import 'package:flashy_flutter/screens/create/create_deck_screen.dart';
import 'package:flashy_flutter/screens/likes/liked_deck_screen.dart';
import 'package:flashy_flutter/screens/login/login_screen.dart';
import 'package:flashy_flutter/screens/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/account/account_screen.dart';
import 'package:flashy_flutter/screens/profile/profile_screen.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/deck_notifier.dart';
import '../../notifiers/category_notifier.dart';
import '../../notifiers/profile_notifier.dart';
import '../../widgets/deck_card.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/error_modal.dart';
import '../categories/category_deck_screen.dart';
import '../user/user_deck_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {

  late ScrollController _scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(deckProvider.notifier).fetchHomeDeckData();
        await ref.read(categoryProvider.notifier).fetchCategoryData();
      } catch (e) {
        showModal(context, 'An Error Occurred', 'Please try again');
      } finally {
        setState(() {
          isLoaded = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scaffoldKey.currentState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState?.openDrawer();
      });
    }
  }

  void _navigateToDeckDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckDetailScreen(id: id, type: 'home',),
      ),
    ).then((result) {
      _scrollController.jumpTo(scrollPosition);
    });
  }

  Future _refreshPage() async {
    try {
      setState(() {
        isLoaded = false;
      });
      await ref.read(deckProvider.notifier).fetchHomeDeckData();
    } catch (e) {
      showModal(context, 'An Error Occurred', 'Please try again');
    } finally {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final deckDataList = ref.watch(deckProvider);
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final user = ref.watch(authProvider);

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen()
                ),
              ).then((result) {
                _scrollController.jumpTo(scrollPosition);
                ref.read(deckProvider.notifier).clearSearchResults();
              });
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
            const SizedBox(height: 80),
            Row(
              children: [
                const SizedBox(width: 10),
                Image.asset(
                  'assets/flashy-logo.png',
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (user != null) ListTile(
              leading: const Icon(
                Icons.my_library_add_outlined,
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
                Icons.thumb_up_outlined,
                color: primary,
              ),
              title: const Text(
                'Liked decks',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LikedDeckScreen()
                  ),
                );
              },
            ),
            if (user != null) ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: primary,
              ),
              title: const Text(
                'My decks',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserDeckScreen()
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: primary,
              ),
              title: const Text(
                'Terms of service',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () async  {
                try {
                  await launchUrl(
                    Uri.parse('https://dpars34.github.io/flashy-terms/'),
                    customTabsOptions: CustomTabsOptions(
                      colorSchemes: CustomTabsColorSchemes.defaults(
                        toolbarColor: secondary,
                      ),
                      shareState: CustomTabsShareState.on,
                      urlBarHidingEnabled: true,
                      showTitle: true,
                      closeButton: CustomTabsCloseButton(
                        icon: CustomTabsCloseButtonIcons.back,
                      ),
                    ),
                    safariVCOptions: const SafariViewControllerOptions(
                      preferredBarTintColor: secondary,
                      preferredControlTintColor: black,
                      barCollapsingEnabled: true,
                      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                    )
                  );
                } catch (e) {
                  showModal(context, 'An Error Occurred', 'Please try again');
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.policy_outlined,
                color: primary,
              ),
              title: const Text(
                'Privacy policy',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () async  {
                try {
                  await launchUrl(
                      Uri.parse('https://dpars34.github.io/flashy-privacy-policy/'),
                      customTabsOptions: CustomTabsOptions(
                        colorSchemes: CustomTabsColorSchemes.defaults(
                          toolbarColor: secondary,
                        ),
                        shareState: CustomTabsShareState.on,
                        urlBarHidingEnabled: true,
                        showTitle: true,
                        closeButton: CustomTabsCloseButton(
                          icon: CustomTabsCloseButtonIcons.back,
                        ),
                      ),
                      safariVCOptions: const SafariViewControllerOptions(
                        preferredBarTintColor: secondary,
                        preferredControlTintColor: black,
                        barCollapsingEnabled: true,
                        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                      )
                  );
                } catch (e) {
                  showModal(context, 'An Error Occurred', 'Please try again');
                }
              },
            ),
            const SizedBox(height: 8),
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
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: isLoaded ?
        SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Popular decks',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...deckDataList.homeDecks.where((category) => category.decks.isNotEmpty).map((category) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${category.category.emoji} ${category.category.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: black,
                                fontSize: 18,
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
                                });
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
                                        _scrollController.jumpTo(scrollPosition);
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
        ) : const Center(
          child: CircularProgressIndicator(),
        ),
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