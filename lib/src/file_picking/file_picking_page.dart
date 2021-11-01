import 'dart:io';

import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:cloudboard/src/user/user_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePickingPage extends StatefulWidget {
  static const String routeName = '/file_picking';

  final UserController userController;
  final StorageController storageController;

  const FilePickingPage({
    Key? key,
    required this.userController,
    required this.storageController,
  }) : super(key: key);

  @override
  State<FilePickingPage> createState() => _FilePickingPageState();
}

class _FilePickingPageState extends State<FilePickingPage> {
  List<String> _files = [];

  @override
  void initState() {
    _loadFiles();
    super.initState();
  }

  Future<void> _loadFiles() async {
    debugPrint('Loading files...');
    final files = await widget.storageController.listFiles();
    setState(() {
      _files = files;
    });
  }

  Future<void> _onRefresh() async {
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _pickFile(context),
        ),
        appBar: AppBar(
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Board',
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    widget.storageController.boardName ==
                            widget.userController.user?.uid
                        ? 'My board'
                        : widget.storageController.boardName,
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                onRefresh: _onRefresh,
                child: Builder(builder: (context) {
                  if (_files.isEmpty) {
                    return Center(
                      child: Text(
                        'No file found',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    scrollDirection: Axis.vertical,
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      return Material(
                        elevation: 4.0,
                        child: ListTile(
                          onTap: () => _openInBrowser(file),
                          title: Text(file),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadFile(file),
                              ),
                              const SizedBox(width: 8.0),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  widget.storageController.deleteFile(file);
                                  _loadFiles();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInBrowser(String file) async {
    final url = await widget.storageController.getDownloadLink(file);
    launch(url);
  }

  Future<void> _downloadFile(String fileName) async {
    String? targetPath = await FilePicker.platform.getDirectoryPath();

    if (targetPath != null) {
      widget.storageController.downloadFileTo(
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
        widget.storageController.uploadFile(
          bytes: firstFile.bytes!,
          name: firstFile.name,
        );
      } else if (firstFile.path != null) {
        widget.storageController.uploadFile(
          file: File(firstFile.path!),
          name: firstFile.name,
        );
      }
      setState(() {
        _files.add(firstFile.name);
      });
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
