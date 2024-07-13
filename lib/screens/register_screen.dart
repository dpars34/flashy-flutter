import 'dart:io';

import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../notifiers/auth_notifier.dart';
import '../notifiers/loading_notifier.dart';
import '../widgets/base_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
                  'Enter your details',
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
                    )
                ),
                const SizedBox(height: 4.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: secondary,
                      width: 1.0
                    )
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  )
                ),
                const SizedBox(height: 4.0),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: secondary,
                          width: 1.0
                      )
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Password confirmation',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  )
                ),
                const SizedBox(height: 4.0),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: secondary,
                          width: 1.0
                      )
                  ),
                  child: TextField(
                    controller: _passwordConfirmationController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                const Text(
                  'Username',
                  style: TextStyle(
                    color: gray,
                    fontSize: 14,
                  )
                ),
                const SizedBox(height: 4.0),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: secondary,
                          width: 1.0
                      )
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
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
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
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
                ),
                const SizedBox(height: 40.0),
                BaseButton(onPressed: _pickImage, text: 'Upload image', outlined: true,),
                const SizedBox(height: 12.0),
                BaseButton(onPressed: () {}, text: 'Next'),
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
