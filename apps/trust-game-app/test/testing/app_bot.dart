import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/app/trust_game_app.dart';
import 'package:app/core/routing/app_router.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_dependencies.dart';

class AppBot {
  AppBot(this.tester);

  final WidgetTester tester;

  Future<void> startApp({
    Widget? home,
    Widget Function(AppRouter router)? homeBuilder,
    AppDependencies? dependencies,
  }) async {
    final resolvedDependencies = dependencies ?? buildTestDependencies();
    final router = AppRouter(dependencies: resolvedDependencies);

    await tester.pumpWidget(
      TrustGameApp(router: router, home: home ?? homeBuilder?.call(router)),
    );
  }

  Future<void> startAppAtRoute({
    required String initialRoute,
    AppDependencies? dependencies,
  }) async {
    final resolvedDependencies = dependencies ?? buildTestDependencies();
    final router = AppRouter(dependencies: resolvedDependencies);

    await tester.pumpWidget(
      MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: buildAppTheme(),
        color: AppColors.background,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: router.onGenerateRoute,
        initialRoute: initialRoute,
      ),
    );
  }
}
