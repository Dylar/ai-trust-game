import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/routing/app_router.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/core/theme/app_theme.dart';

class TrustGameApp extends StatelessWidget {
  TrustGameApp({super.key, this.home, AppDependenciesData? dependencies})
    : dependencies = dependencies ?? AppDependenciesData.defaults();

  final Widget? home;
  final AppDependenciesData dependencies;

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      dependencies: dependencies,
      child: MaterialApp(
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
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: home ?? const HomeScreen(),
      ),
    );
  }
}
