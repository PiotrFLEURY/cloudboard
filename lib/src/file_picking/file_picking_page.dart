import 'dart:io';

import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePickingPage extends StatelessWidget {
  static const String routeName = '/file_picking';

  final StorageController storageController;

  const FilePickingPage({
    Key? key,
    required this.storageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _pickFile(context),
                child: const Text('Pick file'),
              ),
              Expanded(
                child: FutureBuilder(
                  future: storageController.listFiles(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<String> files =
                          (snapshot.data ?? []) as List<String>;
                      return ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return ListTile(
                              title: Text(file),
                              onTap: () => _showDownloadLink(context, file),
                            );
                          });
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
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
      String filePath = result.files.first.path ?? '';
      _showBanner(context, filePath);
      File file = File(filePath);
      storageController.uploadFile(file);
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
