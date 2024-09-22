import 'dart:io';

import 'package:flashy_flutter/screens/register/register_complete_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/custom_input_field.dart';

class RegisterConfirmScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String passwordConfirmation;
  final String username;
  final String bio;
  final File? image;


  const RegisterConfirmScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.username,
    required this.bio,
    required this.image
  }) : super(key: key);

  @override
  ConsumerState<RegisterConfirmScreen> createState() => _RegisterConfirmScreenState();
}

class _RegisterConfirmScreenState extends ConsumerState<RegisterConfirmScreen> {
  void _goBack () {
    Navigator.of(context).pop();
  }

  void _submit () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    try {
      loadingNotifier.showLoading(context);
      await authNotifier.register(
        widget.email,
        widget.password,
        widget.passwordConfirmation,
        widget.username,
        widget.bio,
        widget.image
      );
      await authNotifier.login(
        widget.email,
        widget.password,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterCompleteScreen()),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 401 || e.statusCode == 422) {
          showModal(context, 'Registration Failed', 'Please try again');
        } else {
          showModal(context, 'An Error Occurred', 'Please try again');
        }
      } else {
        showModal(context, 'An Error Occurred', 'Please try again');
      }
    } finally {
      loadingNotifier.hideLoading();
    }
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
                    'Register account',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: primary,
                      fontSize: 20,
                    )
                ),
                const Text(
                    'Check your details',
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
                  widget.email,
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
                Text(
                  widget.password.replaceAll(RegExp('.'), '•'),
                  style: const TextStyle(
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
                Text(
                  widget.password.replaceAll(RegExp('.'), '•'),
                  style: const TextStyle(
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
                  widget.username,
                  style: const TextStyle(
                      color: black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Bio',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  widget.bio,
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
                widget.image != null ? Container(
                  height: 109,
                  width: 109,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    image: DecorationImage(
                      image: FileImage(widget.image!),
                      fit: BoxFit.cover, // Make the image cover the container
                    ),
                  ),
                ):
                Container(
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
                BaseButton(onPressed: _goBack, text: 'Edit details', outlined: true,),
                const SizedBox(height: 12.0),
                BaseButton(onPressed: _submit, text: 'Register'),
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
