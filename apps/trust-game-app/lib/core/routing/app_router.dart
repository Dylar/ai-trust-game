import 'package:app/core/app/app_dependencies.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/home/home_view_model.dart';
import 'package:app/screens/interaction/interaction_screen.dart';
import 'package:app/screens/interaction/interaction_view_model.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen.dart';
import 'package:app/screens/interaction_detail/interaction_detail_view_model.dart';
import 'package:app/screens/loading/loading_screen.dart';
import 'package:app/screens/loading/loading_view_model.dart';
import 'package:app/screens/login/login_screen.dart';
import 'package:app/screens/login/login_view_model.dart';
import 'package:app/screens/session_detail/session_detail_screen.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:app/screens/session_start/session_start_screen.dart';
import 'package:app/screens/session_start/session_start_view_model.dart';
import 'package:flutter/material.dart';

class AppRouter {
  const AppRouter({required this.dependencies});

  final AppDependencies dependencies;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      HomeScreen.routeName => _homeRoute(settings),
      LoginScreen.routeName => _loginRoute(settings),
      SessionStartScreen.routeName => _sessionStartRoute(settings),
      InteractionScreen.routeName => _interactionRoute(settings),
      SessionDetailScreen.routeName => _sessionDetailRoute(settings),
      InteractionDetailScreen.routeName => _interactionDetailRoute(settings),
      _ => _homeRoute(const RouteSettings(name: HomeScreen.routeName)),
    };
  }

  Widget buildHomeScreen() {
    return HomeScreen(
      viewModel: HomeViewModel(
        interactionRepository: dependencies.interactionRepository,
        sessionRepository: dependencies.sessionRepository,
      ),
    );
  }

  Widget buildLoadingScreen() {
    return LoadingScreen(
      viewModel: LoadingViewModel(
        appLogger: dependencies.appLogger,
        authService: dependencies.authService,
        syncService: dependencies.syncService,
      ),
    );
  }

  Widget buildLoginScreen() {
    return LoginScreen(
      viewModel: LoginViewModel(
        appLogger: dependencies.appLogger,
        authService: dependencies.authService,
        userRepository: dependencies.userRepository,
        syncService: dependencies.syncService,
      ),
    );
  }

  Widget buildSessionStartScreen() {
    return SessionStartScreen(
      viewModel: SessionStartViewModel(
        appLogger: dependencies.appLogger,
        sessionService: dependencies.sessionService,
      ),
    );
  }

  Widget buildInteractionScreen({required String sessionId}) {
    return InteractionScreen(
      viewModel: InteractionViewModel(
        appLogger: dependencies.appLogger,
        interactionRepository: dependencies.interactionRepository,
        interactionService: dependencies.interactionService,
        sessionRepository: dependencies.sessionRepository,
        sessionId: sessionId,
      ),
    );
  }

  Widget buildSessionDetailScreen({required String sessionId}) {
    return SessionDetailScreen(
      viewModel: SessionDetailViewModel(
        appLogger: dependencies.appLogger,
        analysisService: dependencies.analysisService,
        sessionId: sessionId,
      ),
    );
  }

  Widget buildInteractionDetailScreen({required String requestId}) {
    return InteractionDetailScreen(
      viewModel: InteractionDetailViewModel(
        appLogger: dependencies.appLogger,
        analysisService: dependencies.analysisService,
        requestId: requestId,
      ),
    );
  }

  Route<void> _homeRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => buildHomeScreen(),
    );
  }

  Route<void> _loginRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => buildLoginScreen(),
    );
  }

  Route<void> _sessionStartRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => buildSessionStartScreen(),
    );
  }

  Route<void> _interactionRoute(RouteSettings settings) {
    final args = settings.arguments as InteractionRouteArgs;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => buildInteractionScreen(sessionId: args.sessionId),
    );
  }

  Route<void> _sessionDetailRoute(RouteSettings settings) {
    final args = settings.arguments as SessionDetailRouteArgs;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => buildSessionDetailScreen(sessionId: args.sessionId),
    );
  }

  Route<void> _interactionDetailRoute(RouteSettings settings) {
    final args = settings.arguments as InteractionDetailRouteArgs;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => buildInteractionDetailScreen(requestId: args.requestId),
    );
  }
}
