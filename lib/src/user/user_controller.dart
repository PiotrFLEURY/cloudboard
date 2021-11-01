import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserController {
  firebase_auth.UserCredential? _userCredential;

  firebase_auth.User? get user =>
      firebase_auth.FirebaseAuth.instance.currentUser;

  firebase_auth.UserCredential? get userCredential => _userCredential;

  bool get authenticated => user != null;

  Future<void> anonymousSignIn() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> googleSignIn() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    _userCredential = await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
