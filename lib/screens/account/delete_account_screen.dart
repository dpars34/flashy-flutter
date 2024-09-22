import 'dart:io';

import 'package:flashy_flutter/screens/account/delete_account_complete_screen.dart';
import 'package:flashy_flutter/screens/account/password_change_complete_screen.dart';
import 'package:flashy_flutter/screens/register/register_confirm_screen.dart';
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

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  String formatValidationErrors(Map<String, dynamic> errors) {
    List<String> errorMessages = [];

    errors.forEach((field, messages) {
      if (messages is List) {
        for (var message in messages) {
          errorMessages.add(message);
        }
      } else {
        errorMessages.add(messages);
      }
    });

    return errorMessages.join('\n\n');
  }

  void _goBack () {
    Navigator.of(context).pop();
  }

  void _deleteAccount () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    if (_formKey.currentState!.validate()) {

      try {
        loadingNotifier.showLoading(context);
        final errors = await authNotifier.checkPassword(
          _passwordController.text,
        );
        if (!mounted) return;
        if (errors.isNotEmpty) {
          String message = formatValidationErrors(errors);
          showModal(context, 'Validation Error', message);
        } else {
          await authNotifier.deleteAccount(
            _passwordController.text
          );
          await authNotifier.logout();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DeleteAccountCompleteScreen()),
          );
        }
      } catch (e) {
        if (e is ApiException) {
          showModal(context, 'An Error Occurred', 'Please try again');
        } else {
          showModal(context, 'An Error Occurred', 'Please try again');
        }
      } finally {
        loadingNotifier.hideLoading();
      }
    } else {
      // showModal(context, 'An Error Occurred', "Please check that the information you have entered is valid and try again.");
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Delete account',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: black,
                          fontSize: 24,
                        )
                    ),
                    const Text(
                        'Are you sure you want to delete your account?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: primary,
                          fontSize: 16,
                        )
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                        'Deleting your account will delete all data associated with your account such as decks, cards and highscores.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: black,
                          fontSize: 14,
                        )
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                        'If you really want to delete your account, enter your password and tap "Delete account"',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: black,
                          fontSize: 14,
                        )
                    ),
                    CustomInputField(
                      controller: _passwordController,
                      labelText: '',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40.0),
                    BaseButton(onPressed: _goBack, text: 'Go back', outlined: true,),
                    const SizedBox(height: 12.0),
                    BaseButton(onPressed: _deleteAccount, text: 'Delete account'),
                    const SizedBox(height: 92.0),
                  ],
                ),
              ),
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
