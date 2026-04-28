import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/app/trust_game_app.dart';
import 'package:app/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_dependencies.dart';

class AppBot {
  AppBot(this.tester);

  final WidgetTester tester;

  Future<void> startApp({
    Widget? home,
    Widget Function(AppRouter router)? homeBuilder,
    AppDependenciesData? dependencies,
  }) async {
    final resolvedDependencies = dependencies ?? buildTestDependencies();
    final router = AppRouter(dependencies: resolvedDependencies);

    await tester.pumpWidget(
      TrustGameApp(
        home: home ?? homeBuilder?.call(router),
        dependencies: resolvedDependencies,
      ),
    );
  }
}
