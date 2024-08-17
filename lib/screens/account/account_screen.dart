import 'dart:io';

import 'package:flashy_flutter/screens/account/account_edit_screen.dart';
import 'package:flashy_flutter/screens/account/delete_account_screen.dart';
import 'package:flashy_flutter/screens/account/password_change_screen.dart';
import 'package:flashy_flutter/screens/register/register_complete_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';

class AccountScreen extends ConsumerStatefulWidget {

  const AccountScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  void _goBack () {
    Navigator.of(context).pop();
  }

  void _toEditScreen () {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AccountEditScreen()
      ),
    );
  }

  void _toPasswordChangeScreen () {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const PasswordChangeScreen()
      ),
    );
  }

  void _toDeleteAccountScreen () {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const DeleteAccountScreen()
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final user = ref.watch(authProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: secondary,
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'My account',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: primary,
                      fontSize: 20,
                    )
                ),
                const Text(
                    'Account details',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: black,
                      fontSize: 16,
                    )
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Email',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  user!.email,
                  style: const TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  '••••••••',
                  style: TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Password confirm',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  '••••••••',
                  style: TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 40.0),
                const Text(
                  'Username',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  user.name,
                  style: const TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                    'Profile picture',
                    style: TextStyle(
                      color: gray,
                      fontSize: 14,
                    )
                ),
                const SizedBox(height: 12.0),
                  user.profileImage != null ? Container(
                    height: 109,
                    width: 109,
                    decoration: BoxDecoration(
                      color: gray2,
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        user.profileImage!,
                        fit: BoxFit.cover,
                        width: 109,
                        height: 109,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: 109,
                              height: 109,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    )
                ): Container(
                  height: 109,
                  width: 109,
                  decoration: BoxDecoration(
                    color: gray2,
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: const Center(
                    child: Icon(
                        Icons.account_circle,
                        size: 50,
                        color: white
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                BaseButton(onPressed: _toEditScreen, text: 'Edit details', outlined: true,),
                const SizedBox(height: 12.0),
                BaseButton(onPressed: _toPasswordChangeScreen, text: 'Change password', outlined: true,),
                const SizedBox(height: 12.0),
                BaseButton(onPressed: _toDeleteAccountScreen, text: 'Delete account'),
                const SizedBox(height: 92.0),
              ],
            ),
          ),
        )
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
