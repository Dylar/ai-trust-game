import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/app/trust_game_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_dependencies.dart';

class AppBot {
  AppBot(this.tester);

  final WidgetTester tester;

  Future<void> startApp({
    Widget? home,
    AppDependenciesData? dependencies,
  }) async {
    await tester.pumpWidget(
      TrustGameApp(
        home: home,
        dependencies: dependencies ?? buildTestDependencies(),
      ),
    );
  }
}
