import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import '../routing/app_router.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/home/home_screen.dart';
import '../theme/app_theme.dart';

class TrustGameApp extends StatelessWidget {
  const TrustGameApp({
    super.key,
    this.home,
    this.dependencies = const AppDependenciesData.defaults(),
  });

  final Widget? home;
  final AppDependenciesData dependencies;

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      dependencies: dependencies,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: buildAppTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: HomeScreen.routeName,
        home: home,
      ),
    );
  }
}
