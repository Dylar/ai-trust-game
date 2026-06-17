import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/routing/app_router.dart';
import 'package:app/screens/login/login_screen.dart';
import 'package:flutter/widgets.dart';

import 'app_bot.dart';

class AppProcess {
  AppProcess(this.appBot);

  final AppBot appBot;

  Future<void> startHome({AppDependencies? dependencies}) async {
    await _startScreen(
      dependencies: dependencies,
      homeBuilder: (router) => router.buildHomeScreen(),
    );
  }

  Future<void> startLoading({AppDependencies? dependencies}) async {
    await _startScreen(
      dependencies: dependencies,
      homeBuilder: (router) => router.buildLoadingScreen(),
    );
  }

  Future<void> startLogin({AppDependencies? dependencies}) async {
    await appBot.startAppAtRoute(
      initialRoute: LoginScreen.routeName,
      dependencies: dependencies,
    );
  }

  Future<void> startSessionStart({AppDependencies? dependencies}) async {
    await _startScreen(
      dependencies: dependencies,
      homeBuilder: (router) => router.buildSessionStartScreen(),
    );
  }

  Future<void> startInteraction({
    required String sessionId,
    AppDependencies? dependencies,
  }) async {
    await _startScreen(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionScreen(sessionId: sessionId),
    );
  }

  Future<void> startSessionDetail({
    required String sessionId,
    AppDependencies? dependencies,
  }) async {
    await _startScreen(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildSessionDetailScreen(sessionId: sessionId),
    );
  }

  Future<void> startInteractionDetail({
    required String requestId,
    AppDependencies? dependencies,
  }) async {
    await _startScreen(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionDetailScreen(requestId: requestId),
    );
  }

  Future<void> _startScreen({
    required Widget Function(AppRouter router) homeBuilder,
    AppDependencies? dependencies,
  }) async {
    await appBot.startApp(dependencies: dependencies, homeBuilder: homeBuilder);
  }
}
