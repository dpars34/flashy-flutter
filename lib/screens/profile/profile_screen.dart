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
  bool loading = true;

  void _goBack () {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile(widget.id);
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
      body: profileUser != null ?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                (profileUser.profileImage != null) ? CircleAvatar(
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
                SizedBox(height: 8),
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
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Bio",
                          style: const TextStyle(
                            color: black,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          )
                      ),
                      SizedBox(height: 8),
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
             ]
            ),
          ),
        ),
      ) :
      Text('LOADING'),
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