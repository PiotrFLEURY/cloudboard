import 'package:cloudboard/src/boards/boards.dart';
import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:cloudboard/src/user/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = '/login';

  final UserController userController;
  final StorageController storageController;

  const LoginPage({
    Key? key,
    required this.userController,
    required this.storageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal[800],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Login page',
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.account_circle),
                      SizedBox(width: 8),
                      Text('Google Login'),
                    ],
                  ),
                  onPressed: null, //() => _googleSingIn(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.account_circle),
                      SizedBox(width: 8),
                      Text('Anonymous login'),
                    ],
                  ),
                  onPressed: () => _anonymousSignIn(context),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _anonymousSignIn(BuildContext context) async {
    await userController.anonymousSignIn();
    storageController.boardName = userController.user?.uid;
    Navigator.of(context).pushReplacementNamed(Boards.routeName);
  }

  Future<void> _googleSingIn(BuildContext context) async {
    try {
      userController.googleSignIn();
      storageController.boardName = userController.user?.uid;
      Navigator.of(context).pushReplacementNamed(Boards.routeName);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
