import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/routing/app_router.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/core/theme/app_theme.dart';

class TrustGameApp extends StatelessWidget {
  const TrustGameApp({super.key, this.home, required this.dependencies});

  final Widget? home;
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(dependencies: dependencies);

    return MaterialApp(
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
      home: home ?? router.buildHomeScreen(),
    );
  }
}
