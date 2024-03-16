import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final String isVerified;
  final List<dynamic> notifications;
  final String phoneNumber; // Added phone number field
  final String phoneNumberVerified; // Added phone number verified field

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    required this.isVerified,
    required this.notifications,
    required this.phoneNumber, // Initialize phone number in constructor
    required this.phoneNumberVerified, // Initialize phone number verified in constructor
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      followers: snapshot["followers"],
      following: snapshot["following"],
      isVerified: snapshot["isVerified"],
      notifications: snapshot["notifications"],
      phoneNumber: snapshot["phoneNumber"], // Extract phone number from snapshot
      phoneNumberVerified: snapshot["phoneNumberVerified"], // Extract phone number verified status from snapshot
    );
  }

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "photoUrl": photoUrl,
    "bio": bio,
    "followers": followers,
    "following": following,
    "isVerified": isVerified,
    "notifications": notifications,
    "phoneNumber": phoneNumber, // Include phone number in JSON
    "phoneNumberVerified": phoneNumberVerified, // Include phone number verified status in JSON
  };
}
