// import 'dart:io';
//
// import 'package:flashy_flutter/screens/register/register_complete_screen.dart';
// import 'package:flashy_flutter/utils/api_exception.dart';
// import 'package:flashy_flutter/widgets/error_modal.dart';
// import 'package:flutter/material.dart';
// import 'package:flashy_flutter/utils/colors.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../../notifiers/auth_notifier.dart';
// import '../../notifiers/loading_notifier.dart';
// import '../../widgets/base_button.dart';
// import 'account_edit_complete_screen.dart';
//
// class AccountEditConfirmScreen extends ConsumerStatefulWidget {
//   final String email;
//   final String username;
//   final File? image;
//   final bool updateImage;
//   final String? imageUrl;
//
//   const AccountEditConfirmScreen({
//     Key? key,
//     required this.email,
//     required this.username,
//     required this.image,
//     required this.updateImage,
//     required this.imageUrl,
//   }) : super(key: key);
//
//   @override
//   ConsumerState<AccountEditConfirmScreen> createState() => _AccountEditConfirmScreenState();
// }
//
// class _AccountEditConfirmScreenState extends ConsumerState<AccountEditConfirmScreen> {
//   void _goBack () {
//     Navigator.of(context).pop();
//   }
//
//   void _submit () async {
//     final loadingNotifier = ref.read(loadingProvider.notifier);
//     final authNotifier = ref.watch(authProvider.notifier);
//
//     try {
//       loadingNotifier.showLoading(context);
//       await authNotifier.edit(
//           widget.email,
//           widget.username,
//           widget.image,
//           widget.updateImage,
//       );
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AccountEditCompleteScreen()),
//         );
//       }
//     } catch (e) {
//       if (e is ApiException) {
//         if (e.statusCode == 401 || e.statusCode == 422) {
//           showModal(context, 'Registration Failed', 'Please try again');
//         } else {
//           showModal(context, 'An Error Occurred', 'Please try again');
//         }
//       } else {
//         showModal(context, 'An Error Occurred', 'Please try again');
//       }
//     } finally {
//       loadingNotifier.hideLoading();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Fetch the deck data when the widget is initialized
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authNotifier = ref.watch(authProvider.notifier);
//     final loadingNotifier = ref.read(loadingProvider.notifier);
//
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: secondary,
//           title: const Text(''),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                     'Edit details',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       color: primary,
//                       fontSize: 20,
//                     )
//                 ),
//                 const Text(
//                     'Check your details',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       color: black,
//                       fontSize: 16,
//                     )
//                 ),
//                 const SizedBox(height: 24.0),
//                 const Text(
//                   'Email',
//                   style: TextStyle(
//                     color: gray,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4.0),
//                 Text(
//                   widget.email,
//                   style: const TextStyle(
//                       color: black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 const Text(
//                   'Username',
//                   style: TextStyle(
//                     color: gray,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4.0),
//                 Text(
//                   widget.username,
//                   style: const TextStyle(
//                       color: black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800
//                   ),
//                 ),
//                 const SizedBox(height: 12.0),
//                 const Text(
//                     'Profile picture',
//                     style: TextStyle(
//                       color: gray,
//                       fontSize: 14,
//                     )
//                 ),
//                 const SizedBox(height: 12.0),
//                 widget.updateImage ? widget.image != null ? Container(
//                   height: 109,
//                   width: 109,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     image: DecorationImage(
//                       image: FileImage(widget.image!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ) :
//                 Container(
//                   height: 109,
//                   width: 109,
//                   decoration: BoxDecoration(
//                     color: gray2,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Center(
//                     child: Icon(
//                         Icons.account_circle,
//                         size: 50,
//                         color: white
//                     ),
//                   ),
//                 )
//                     : widget.imageUrl != null ? Container(
//                     height: 109,
//                     width: 109,
//                     decoration: BoxDecoration(
//                       color: gray2,
//                       borderRadius: BorderRadius.circular(12), // Rounded corners
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         widget.imageUrl!,
//                         fit: BoxFit.cover,
//                         width: 109,
//                         height: 109,
//                         loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Container(
//                               width: 109,
//                               height: 109,
//                               color: Colors.white,
//                             ),
//                           );
//                         },
//                       ),
//                     )
//                 ) :
//                 Container(
//                   height: 109,
//                   width: 109,
//                   decoration: BoxDecoration(
//                     color: gray2,
//                     borderRadius: BorderRadius.circular(12), // Rounded corners
//                   ),
//                   child: const Center(
//                     child: Icon(
//                         Icons.add,
//                         size: 50,
//                         color: white
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40.0),
//                 BaseButton(onPressed: _goBack, text: 'Go back', outlined: true,),
//                 const SizedBox(height: 12.0),
//                 BaseButton(onPressed: _submit, text: 'Save'),
//                 const SizedBox(height: 92.0),
//               ],
//             ),
//           ),
//         )
//     );
//   }
// }
//
// void showModal(BuildContext context, String title, String content) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return ErrorModal(title: title, content: content, context: context);
//     },
//   );
// }
