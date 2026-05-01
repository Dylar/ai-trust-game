import 'package:flutter/material.dart';

abstract final class HomeKeys {
  static const screen = Key('home.screen');
  static const title = Key('home.title');
  static const startSessionButton = Key('home.start_session_button');
  static const recentSessionsSection = Key('home.recent_sessions_section');
  static const emptySessionsState = Key('home.empty_sessions_state');

  static const sessionGuestEasy = ValueKey<String>('home.session.guest_easy');
  static const sessionEmployeeMedium = ValueKey<String>(
    'home.session.employee_medium',
  );
  static const sessionAdminHard = ValueKey<String>('home.session.admin_hard');

  static ValueKey<String> session(String id) {
    return switch (id) {
      'guest_easy' => sessionGuestEasy,
      'employee_medium' => sessionEmployeeMedium,
      'admin_hard' => sessionAdminHard,
      _ => ValueKey<String>('home.session.$id'),
    };
  }
}
