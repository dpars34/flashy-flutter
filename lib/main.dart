import 'dart:convert';

import 'package:flashy_flutter/screens/home/home_screen.dart';
import 'package:flashy_flutter/screens/login/login_screen.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifiers/loading_notifier.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
      ),
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
  }
}
