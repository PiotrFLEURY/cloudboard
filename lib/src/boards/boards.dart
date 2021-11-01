import 'package:cloudboard/src/file_picking/file_picking_page.dart';
import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:cloudboard/src/user/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Boards extends StatefulWidget {
  static const routeName = '/boards';

  final UserController userController;
  final StorageController storageController;

  const Boards({
    Key? key,
    required this.userController,
    required this.storageController,
  }) : super(key: key);

  @override
  State<Boards> createState() => _BoardsState();
}

class _BoardsState extends State<Boards> {
  late List<String> _boards;

  @override
  void initState() {
    _boards = widget.storageController.availableBoards;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _searchBoard(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            _addBoard(context);
          }),
      body: Column(
        children: [
          Material(
            elevation: 4.0,
            color: Theme.of(context).primaryColor,
            child: Text(
              'Choose a board',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _boards.length,
              itemBuilder: (context, index) {
                return Material(
                  elevation: 4.0,
                  child: ListTile(
                    title: Text(
                      asPrettyBoardName(_boards[index]),
                    ),
                    onTap: () {
                      widget.storageController.boardName = _boards[index];
                      Navigator.of(context).pushNamed(
                        FilePickingPage.routeName,
                      );
                    },
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _pickBoardName(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter a name for the new board',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );
  }

  Future<void> _searchBoard(BuildContext context) async {
    final newBoardName = await _pickBoardName(context);
    String finalName =
        widget.storageController.addBoard(newBoardName, generate: false);
    setState(() {
      _boards.add(finalName);
    });
  }

  Future<void> _addBoard(BuildContext context) async {
    final newBoardName = await _pickBoardName(context);
    String finalName = widget.storageController.addBoard(newBoardName);
    setState(() {
      _boards.add(finalName);
    });
  }

  String asPrettyBoardName(String boardName) {
    if (boardName == widget.userController.user?.uid) {
      return 'My Board';
    }
    return boardName;
  }
}
