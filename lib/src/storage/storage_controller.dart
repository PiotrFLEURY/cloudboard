import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';

class StorageController {
  String boardName = 'uploads';

  /// The user selects a file, and the task is added to the list.
  Future<firebase_storage.UploadTask> uploadFile(
    Uint8List bytes,
    String name,
  ) async {
    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(boardName)
        .child(name);

    final metadata = firebase_storage.SettableMetadata(
        contentType: getContentType(name),
        customMetadata: {
          'picked-file-path': name,
        });

    if (kIsWeb) {
      uploadTask = ref.putData(bytes, metadata);
    } else {
      uploadTask = ref.putFile(File.fromRawPath(bytes), metadata);
    }

    return Future.value(uploadTask);
  }

  /// Function to compute the content type regarding the file extension
  String getContentType(String name) {
    final extension = name.split('.').last;
    switch (extension) {
      case 'jpg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<List<String>> listFiles() async {
    firebase_storage.ListResult listResult = await firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(boardName)
        .listAll();

    return listResult.items.map((item) => item.name).toList();
  }

  Future<String> getDownloadLink(String fileName) async {
    return firebase_storage.FirebaseStorage.instance
        .ref()
        .child(boardName)
        .child(fileName)
        .getDownloadURL();
  }

  Future<void> downloadFileTo(String fileName, String targetPath) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(boardName)
        .child(fileName);
    final File tempFile = File('$targetPath/downloaded-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);
  }
}
