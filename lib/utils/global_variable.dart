import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernsocialapp/screens/add_post_screen.dart';
import 'package:modernsocialapp/screens/feed_screen.dart';
import 'package:modernsocialapp/screens/notification_screen.dart';
import 'package:modernsocialapp/screens/profile_screen.dart';
import 'package:modernsocialapp/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> getHomeScreenItems() {
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserUid == null) {
    // Handle the case where there is no user logged in
    // This could redirect to a login screen or display an error message
    // For this example, let's assume we redirect to a login screen
    return [
      const FeedScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const NotificationsPage(),
      // Potentially a placeholder screen urging the user to log in
    ];
  } else {
    return [
      const FeedScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const NotificationsPage(),
      ProfileScreen(uid: currentUserUid),
    ];
  }
}

