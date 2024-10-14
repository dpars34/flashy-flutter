import 'dart:convert';

import 'package:flashy_flutter/screens/deck/deck_detail_screen.dart';
import 'package:flashy_flutter/screens/home/home_screen.dart';
import 'package:flashy_flutter/screens/login/login_screen.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'notifiers/auth_notifier.dart';
import 'notifiers/deck_notifier.dart';
import 'notifiers/loading_notifier.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures Flutter is fully initialized before Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isFirebaseMessagingInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay the notification handling until the home screen is shown
    });
  }

  void _handleNotificationTap(Map<String, dynamic> data, WidgetRef ref) async {
    if (data['notification_type'] == 'deck_link') {
      await ref.read(deckProvider.notifier).fetchNotificationDeck(int.parse(data['deck_id']));
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => DeckDetailScreen(
            id: int.parse(data['deck_id']),
            type: 'notification',
          ),
        ),
      );
    }
  }

  void _setupFirebaseMessaging (WidgetRef ref) {
    final user = ref.watch(authProvider);

    // Request permission on iOS
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        // Extract the data and navigate accordingly
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      if (message.data.isNotEmpty) {
        // Extract the data and navigate accordingly
        _handleNotificationTap(message.data, ref);
      }
    });

    // Check if the app was opened from a terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        // Handle notification tap when the app was terminated
      }
    });

    // Get token for sending notifications
    _firebaseMessaging.getToken().then((String? token) {
      if (user != null) {
        ref.read(authProvider.notifier).sendFcmToken(token!);
      }
    });

    _isFirebaseMessagingInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      if (!_isFirebaseMessagingInitialized) {
        _setupFirebaseMessaging(ref);
      }

      return MaterialApp(
        title: 'Flashy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        routes: {
          '/login': (context) => const LoginScreen(),
        },
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              Consumer(builder: (context, ref, _) {
                final isLoading = ref.watch(loadingProvider).isLoading;
                return isLoading ? Material(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : const SizedBox.shrink();
              }),
            ],
          );
        },
        home: const HomeScreen(),
      );
    });
  }
}
