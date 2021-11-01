import 'dart:io';

import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:cloudboard/src/user/user_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePickingPage extends StatelessWidget {
  static const String routeName = '/file_picking';

  final UserController userController;
  final StorageController storageController;

  const FilePickingPage({
    Key? key,
    required this.userController,
    required this.storageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _pickFile(context),
        ),
        appBar: AppBar(
          title: Text(
            storageController.boardName == userController.user?.uid
                ? 'My board'
                : storageController.boardName,
          ),
        ),
        body: FutureBuilder(
          future: storageController.listFiles(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<String> files = (snapshot.data ?? []) as List<String>;
              if (files.isEmpty) {
                return const Center(
                  child: Text('No files'),
                );
              }
              return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ListTile(
                      title: Text(file),
                      onTap: () => _showDownloadLink(context, file),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 24.0,
                      ),
                    );
                  });
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> _showDownloadLink(BuildContext context, String file) async {
    final url = await storageController.getDownloadLink(file);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download link'),
        content: Text(url),
        actions: [
          TextButton(
            child: const Text('Open'),
            onPressed: () {
              launch(url);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Download'),
            onPressed: () async {
              _downloadFile(file);

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String fileName) async {
    String? targetPath = await FilePicker.platform.getDirectoryPath();

    if (targetPath != null) {
      storageController.downloadFileTo(
        fileName,
        targetPath,
      );
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      var firstFile = result.files.first;
      if (kIsWeb) {
        storageController.uploadFile(
          bytes: firstFile.bytes!,
          name: firstFile.name,
        );
      } else if (firstFile.path != null) {
        storageController.uploadFile(
          file: File(firstFile.path!),
          name: firstFile.name,
        );
      }
    } else {
      // User canceled the picker
      _showBanner(context, 'User canceled the picker');
    }
  }

  void _showBanner(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        actions: [
          IconButton(
            onPressed: () => _hideBanner(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  void _hideBanner(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }
}
