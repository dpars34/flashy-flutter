import 'package:flashy_flutter/screens/create/create_deck_screen.dart';
import 'package:flashy_flutter/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../notifiers/profile_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/error_modal.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isLoaded = false;

  void _goBack () {
    Navigator.of(context).pop();
  }

  Future _refreshPage() async {
    try {
      setState(() {
        isLoaded = false;
      });
      ref.read(profileProvider.notifier).loadProfile(widget.id);
    } catch (e) {
      if (!mounted) return;
      showModal(context, 'An Error Occurred', 'Please try again');
    } finally {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(profileProvider.notifier).loadProfile(widget.id);
      } catch (e) {
        if (!mounted) return;
        showModal(context, 'An Error Occurred', 'Please try again');
      } finally {
        setState(() {
          isLoaded = true;
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    final profileUser = ref.watch(profileProvider);

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    String formatDate (DateTime timestamp) {
      String formattedDate = DateFormat('MMMM yyyy').format(timestamp);
      return formattedDate;
    }

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondary,
      ),
      body: isLoaded ?
      RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              child: profileUser == null ? const Column(
                children: [
                  Icon(
                    Icons.person,
                    color: gray2,
                    size: 100,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "User couldn't be found!",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: gray,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ) : Column(
                children: [
                  (profileUser!.profileImage != null) ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileUser.profileImage!),
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Error loading image: $exception');
                    },
                  ) : const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: gray2
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileUser.name,
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    )
                  ),
                  Text(
                      'User since: ${formatDate(profileUser.createdAt)}',
                      style: const TextStyle(
                        color: black,
                        fontSize: 14,
                      )
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            "Bio",
                            style: TextStyle(
                              color: black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            )
                        ),
                        const SizedBox(height: 8),
                        Text(
                            profileUser.bio,
                            style: const TextStyle(
                              color: black,
                              fontSize: 14,
                            )
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  BaseButton(onPressed: _goBack, text: 'Go back', outlined: true,),
                  const SizedBox(height: 150),
               ]
              ),
            ),
          ),
        ),
      ) : const Center(
        child: CircularProgressIndicator(),
      ),
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