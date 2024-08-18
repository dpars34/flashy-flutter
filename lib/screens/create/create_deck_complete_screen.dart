import 'package:flashy_flutter/screens/home/home_screen.dart';
import 'package:flashy_flutter/widgets/base_button.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class CreateDeckCompleteScreen extends StatefulWidget {
  const CreateDeckCompleteScreen({super.key});

  @override
  State<CreateDeckCompleteScreen> createState() => _CreateDeckCompleteScreenState();
}

class _CreateDeckCompleteScreenState extends State<CreateDeckCompleteScreen> {
  void _goToAccount () {
    Navigator.of(context).pop();
  }

  void _goHome () {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: secondary,
          automaticallyImplyLeading: false,
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/flashy-icon.png',
                  height: 75,
                ),
                SizedBox(height: 12),
                const Text(
                  'Thank you!\n Your deck has been submitted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: black,
                      fontSize: 20
                  ),
                ),
                const SizedBox(height: 60),
                BaseButton(onPressed: _goHome, text: 'To Home Screen')
              ],
            ),
          ),
        )
    );
  }
}
