import 'dart:io';

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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final loadingNotifier = ref.read(loadingProvider.notifier);

    try {
      loadingNotifier.showLoading(context);
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      showModal(context, 'An Error Occurred', "Your image couldn't be uploaded. Please try again or try another image.");
    } finally {
      loadingNotifier.hideLoading();
    }
  }

  void _deleteImage () {
    setState(() {
      _image = null;
    });
  }

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

  void _toNextPage () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    if (_formKey.currentState!.validate()) {

      try {
        // SEND TO VALIDATION API
        loadingNotifier.showLoading(context);
        final errors = await authNotifier.validate(
          _emailController.text,
          _passwordController.text,
          _passwordConfirmationController.text,
          _usernameController.text,
          _bioController.text,
          _image,
        );
        if (!mounted) return;
        if (errors.isNotEmpty) {
          String message = formatValidationErrors(errors);
          showModal(context, 'Validation Error', message);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterConfirmScreen(
                  email: _emailController.text,
                  password: _passwordController.text,
                  passwordConfirmation: _passwordConfirmationController.text,
                  username: _usernameController.text,
                  bio: _bioController.text,
                  image: _image
              ),
            ),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
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
                    'Enter your details',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: black,
                      fontSize: 16,
                    )
                  ),
                  const SizedBox(height: 24.0),
                  CustomInputField(
                    controller: _emailController,
                    labelText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  CustomInputField(
                    controller: _passwordController,
                    labelText: 'Password',
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
                    labelText: 'Password confirmation',
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
                  CustomInputField(
                    controller: _usernameController,
                    labelText: 'Username',
                    maxLength: 30,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  CustomInputField(
                    controller: _bioController,
                    labelText: 'Bio',
                    minLines: 3,
                    maxLines: 3,
                    maxLength: 200,
                    validator: (value) {
                      return null;
                    },
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image != null ? Container(
                      height: 109,
                      width: 109,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        image: DecorationImage(
                          image: FileImage(_image!),
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
                          Icons.add,
                          size: 50,
                          color: white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  _image != null ? BaseButton(onPressed: _deleteImage, text: 'Delete image', outlined: true,) :
                    BaseButton(onPressed: _pickImage, text: 'Upload image', outlined: true,),
                  const SizedBox(height: 12.0),
                  BaseButton(onPressed: _toNextPage, text: 'Next'),
                  const SizedBox(height: 92.0),
                ],
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
