import 'package:flashy_flutter/screens/home/home_screen.dart';
import 'package:flashy_flutter/widgets/base_button.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class AccountEditCompleteScreen extends StatefulWidget {
  const AccountEditCompleteScreen({super.key});

  @override
  State<AccountEditCompleteScreen> createState() => _AccountEditCompleteScreenState();
}

class _AccountEditCompleteScreenState extends State<AccountEditCompleteScreen> {
  void _goToAccount () {
    Navigator.of(context).pop();
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
                  'You changes have been saved!',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: black,
                      fontSize: 20
                  ),
                ),
                const SizedBox(height: 60),
                BaseButton(onPressed: _goHome, text: 'To Home Screen', outlined: true,),
                const SizedBox(height: 12),
                BaseButton(onPressed: _goToAccount, text: 'To Account Screen')
              ],
            ),
          ),
        )
    );
  }
}
