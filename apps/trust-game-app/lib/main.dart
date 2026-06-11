import 'package:flutter/material.dart';

import 'core/app/app_dependencies.dart';
import 'core/app/trust_game_app.dart';
import 'core/routing/app_router.dart';
import 'screens/home/home_screen.dart';

void main() {
  final dependencies = AppDependencies.defaults();
  final router = AppRouter(dependencies: dependencies);
  runApp(
    TrustGameApp(
      dependencies: dependencies,
      home: Builder(
        builder: (context) {
          return router.buildLoadingScreen(
            onLoaded: (_) {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          );
        },
      ),
    ),
  );
}
