import 'package:cloudboard/src/file_picking/file_picking_page.dart';
import 'package:cloudboard/src/storage/storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class MyApp extends StatelessWidget {
  final StorageController storageController;
  const MyApp({
    Key? key,
    required this.storageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      firebase_auth.FirebaseAuth.instance.signInAnonymously();
    }
    return MaterialApp(
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
              case FilePickingPage.routeName:
              default:
                return FilePickingPage(
                  storageController: storageController,
                );
            }
          },
        );
      },
    );
  }
}