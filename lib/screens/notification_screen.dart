import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modernsocialapp/resources/auth_methods.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uid = AuthMethods().getCurrentUserUid();

  Stream<List<String>> getNotificationsStream() {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.data()?['notifications'];
      if (notifications is List) {
        // Assuming 'notifications' is a list of strings
        return List<String>.from(notifications);
      }
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No notifications found'));
        }
        final notifications = snapshot.data!;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(notifications[index]),
            );
          },
        );
      },
    );
  }
}
