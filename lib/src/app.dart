import 'package:cloudboard/src/boards/boards.dart';
import 'package:cloudboard/src/file_picking/file_picking_page.dart';
import 'package:cloudboard/src/login/login.dart';
import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:cloudboard/src/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  final UserController userController;
  final StorageController storageController;
  const MyApp({
    Key? key,
    required this.storageController,
    required this.userController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case Boards.routeName:
                return Boards(
                  userController: userController,
                  storageController: storageController,
                );
              case FilePickingPage.routeName:
                return FilePickingPage(
                  userController: userController,
                  storageController: storageController,
                );
              case LoginPage.routeName:
              default:
                return LoginPage(
                  userController: userController,
                  storageController: storageController,
                );
            }
          },
        );
      },
    );
  }
}
