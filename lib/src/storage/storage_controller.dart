import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';

class StorageController {
  late String _boardName;
  final Set<String> _availableBoards = <String>{};

  String get boardName => _boardName;

  List<String> get availableBoards => _availableBoards.toList();

  set boardName(String? value) {
    if (value == null) {
      _boardName = 'uploads';
    } else {
      _boardName = value;
    }
    _availableBoards.add(_boardName);
  }

  /// The user selects a file, and the task is added to the list.
  Future<firebase_storage.UploadTask> uploadFile({
    File? file,
    Uint8List? bytes,
    required String name,
  }) async {
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
      uploadTask = ref.putData(bytes!, metadata);
    } else {
      uploadTask = ref.putFile(file!, metadata);
    }

    return Future.value(uploadTask);
  }

  /// Function to compute the content type regarding the file extension
  String getContentType(String name) {
    final extension = name.split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
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

  String addBoard(newBoardName, {bool generate = true}) {
    if (generate) {
      int randomId = Random().nextInt(9999);
      String generatedName = '$newBoardName-$randomId';
      _availableBoards.add(generatedName);
      return generatedName;
    }
    _availableBoards.add(newBoardName);
    return newBoardName;
  }

  void deleteFile(String file) {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child(boardName)
        .child(file)
        .delete();
  }
}
