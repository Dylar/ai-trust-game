import 'package:flutter/material.dart';

import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen.dart';
import 'package:app/screens/interaction/interaction_screen.dart';
import 'package:app/screens/session_detail/session_detail_screen.dart';
import 'package:app/screens/session_start/session_start_screen.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      HomeScreen.routeName => _homeRoute(settings),
      SessionStartScreen.routeName => _sessionStartRoute(settings),
      InteractionScreen.routeName => _interactionRoute(settings),
      SessionDetailScreen.routeName => _sessionDetailRoute(settings),
      InteractionDetailScreen.routeName => _interactionDetailRoute(settings),
      _ => _homeRoute(const RouteSettings(name: HomeScreen.routeName)),
    };
  }

  static Route<void> _homeRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const HomeScreen(),
    );
  }

  static Route<void> _sessionStartRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const SessionStartScreen(),
    );
  }

  static Route<void> _interactionRoute(RouteSettings settings) {
    final args = settings.arguments as InteractionRouteArgs;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => InteractionScreen(sessionId: args.sessionId),
    );
  }

  static Route<void> _sessionDetailRoute(RouteSettings settings) {
    final args = settings.arguments as SessionDetailRouteArgs;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => SessionDetailScreen(sessionId: args.sessionId),
    );
  }

  static Route<void> _interactionDetailRoute(RouteSettings settings) {
    final args = settings.arguments as InteractionDetailRouteArgs;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => InteractionDetailScreen(requestId: args.requestId),
    );
  }
}
