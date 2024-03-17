import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernsocialapp/models/user.dart' as model;
import 'package:modernsocialapp/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required String phoneNumber,
    required Uint8List file,
  }) async {
    String res = "Some error Occurred";
    try {
      // Checking that none of the fields are empty
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && bio.isNotEmpty && file != null) {
        // Registering user in FirebaseAuth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Uploading profile picture to Firebase Storage and getting the URL
        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        // Creating a new user object with the provided details
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          isVerified: "false",
          notifications: [],
          phoneNumber: phoneNumber, // Assuming phone number is not provided at sign-up
          phoneNumberVerified: 'false', // Assuming phone number is not verified at sign-up
        );

        // Adding user data to Firestore
        await _firestore.collection("users").doc(cred.user!.uid).set(user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> resetPassword({required String email}) async {
    if(email.isEmpty){
      return 'Please enter your email!';
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } catch (err) {
      return err.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? getCurrentUserUid() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    return user?.uid; // This will return the UID of the currently signed-in user or null if no user is signed in.
  }
}
