import 'dart:io';

import 'package:flashy_flutter/screens/account/password_change_complete_screen.dart';
import 'package:flashy_flutter/screens/register/register_confirm_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/custom_input_field.dart';

class PasswordChangeScreen extends ConsumerStatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

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

  void _toNextPage () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    if (_formKey.currentState!.validate()) {

      try {
        // SEND TO VALIDATION API
        loadingNotifier.showLoading(context);
        final errors = await authNotifier.validateOldPassword(
          _oldPasswordController.text
        );
        if (!mounted) return;
        if (errors.isNotEmpty) {
          String message = formatValidationErrors(errors);
          showModal(context, 'Validation Error', message);
        } else {
          await authNotifier.changePassword(
            _oldPasswordController.text,
            _passwordController.text,
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PasswordChangeCompleteScreen()),
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
      HapticFeedback.heavyImpact();
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
                        'Change password',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: black,
                          fontSize: 24,
                        )
                    ),
                    // const Text(
                    //     '',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.w500,
                    //       color: black,
                    //       fontSize: 16,
                    //     )
                    // ),
                    const SizedBox(height: 24.0),
                    CustomInputField(
                      controller: _oldPasswordController,
                      labelText: 'Old Password',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    CustomInputField(
                      controller: _passwordController,
                      labelText: 'New password',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    CustomInputField(
                      controller: _passwordConfirmationController,
                      labelText: 'New password confirmation',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40.0),
                    BaseButton(onPressed: _goBack, text: 'Go back', outlined: true,),
                    const SizedBox(height: 12.0),
                    BaseButton(onPressed: _toNextPage, text: 'Change password'),
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
