import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await firebase_core.Firebase.initializeApp();

  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) {
    await firebase_auth.FirebaseAuth.instance.signInAnonymously();
  }

  StorageController storageController = StorageController();
  runApp(
    MyApp(
      storageController: storageController,
    ),
  );
}
