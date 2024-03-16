import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:modernsocialapp/models/post.dart';
import 'package:modernsocialapp/resources/auth_methods.dart';
import 'package:modernsocialapp/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });

        var documentSnapshot = await _firestore.collection('posts').doc(postId).get();
        String postOwnerId = documentSnapshot.data()?['uid']; // assuming 'ownerId' is the field name
        String? username = await getUsernameByUid(uid);
        await createNotification(postOwnerId, '${username!} has liked your post.');
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        var documentSnapshot = await _firestore.collection('posts').doc(postId).get();
        String postOwnerId = documentSnapshot.data()?['uid']; // assuming 'ownerId' is the field name
        String? username = await getUsernameByUid(uid);
        await createNotification(postOwnerId, '${username!} has commented on your post.');
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> createNotification(String targetUserId,  String message) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(targetUserId);

      DocumentSnapshot snapshot = await userDocRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
        List<String> notifications = (data['notifications'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ?? [];
        notifications.add(message); // Add your message regardless of duplicates

        await userDocRef.update({
          'notifications': notifications
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
      // Handle any errors here
    }
  }



  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      String? username = await getUsernameByUid(uid);
      String? username2 = await getUsernameByUid(followId);

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
        await createNotification(followId, '${username!} has unfollowed you.');
        await createNotification(uid, 'You have unfollowed ${username2!}.');
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
        await createNotification(followId, '${username!} has started following you.');
        await createNotification(uid, 'You have started followig ${username2!}.');
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<String?> getUsernameByUid(String uid) async {
    try {
      // Perform a query on the 'users' collection where 'uid' matches the provided uid
      var userDocument = await _firestore.collection('users').doc(uid).get();

      // Check if a document with the given UID exists
      if (userDocument.exists) {
        // If the document exists, extract the username field
        String username = userDocument.data()?["username"] ?? "Username not found";
        return username;
      } else {
        // If no document found, return null or handle appropriately
        return null;
      }
    } catch (e) {
      // Handle errors (e.g., network issues, permission problems)
      print("Error getting user by UID: $e");
      return null;
    }
  }

  Future<List<String>> getUserNotifications() async {
    // Reference to Firestore collection and specific document
    DocumentReference<Map<String, dynamic>> userDocRef = FirebaseFirestore.instance.collection('users').doc(AuthMethods().getCurrentUserUid());

    // Attempt to fetch the document
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await userDocRef.get();

    // Check if the document exists and has data
    if (docSnapshot.exists && docSnapshot.data() != null) {
      // Attempt to read the 'notifications' field as a List<String>
      List<String> notifications = List<String>.from(docSnapshot.data()!['notifications'] ?? []);
      return notifications;
    } else {
      // Handle the case where the document does not exist or doesn't contain the 'notifications' field
      return [];
    }
  }
}
