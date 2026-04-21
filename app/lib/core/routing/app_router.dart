import 'package:flutter/material.dart';

import '../../screens/home/home_screen.dart';
import '../../screens/session_start/session_start_screen.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      HomeScreen.routeName => _homeRoute(settings),
      SessionStartScreen.routeName => _sessionStartRoute(settings),
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
}
