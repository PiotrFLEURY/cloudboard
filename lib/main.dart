import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();

  StorageController storageController = StorageController();
  runApp(
    MyApp(
      storageController: storageController,
    ),
  );
}
