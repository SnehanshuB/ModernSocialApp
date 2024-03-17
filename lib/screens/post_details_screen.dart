import 'package:flutter/material.dart';
import 'package:modernsocialapp/responsive/mobile_screen_layout.dart';

import '../utils/colors.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostDetailScreen({Key? key, required this.postData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(postData['username'] ?? 'Post'), // Fallback to 'Post' if username is not available
        backgroundColor: mobileBackgroundColor,
      ),
      body: SingleChildScrollView(child: PostCard(snap: postData)), // Use PostCard to display the post
    );
  }
}
