import 'package:flutter/material.dart';

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
      body: PostCard(snap: postData), // Use PostCard to display the post
    );
  }
}
