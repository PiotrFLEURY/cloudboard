import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';

class StorageController {
  /// The user selects a file, and the task is added to the list.
  Future<firebase_storage.UploadTask> uploadFile(File file) async {
    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('uploads')
        .child(file.path.split('/').last);

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path});

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

  Future<List<String>> listFiles() async {
    firebase_storage.ListResult listResult = await firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('uploads')
        .listAll();

    return listResult.items.map((item) => item.name).toList();
  }

  Future<String> getDownloadLink(String fileName) async {
    return firebase_storage.FirebaseStorage.instance
        .ref()
        .child('uploads')
        .child(fileName)
        .getDownloadURL();
  }

  Future<void> downloadFileTo(String fileName, String targetPath) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('uploads')
        .child(fileName);
    final File tempFile = File('$targetPath/downloaded-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);
  }
}
