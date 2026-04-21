import 'package:flutter/material.dart';

abstract final class HomeKeys {
  static const screen = Key('home.screen');
  static const title = Key('home.title');
  static const startSessionButton = Key('home.start_session_button');
  static const recentSessionsSection = Key('home.recent_sessions_section');
  static const emptySessionsState = Key('home.empty_sessions_state');

  static const sessionGuestEasy = Key('home.session.guest_easy');
  static const sessionEmployeeMedium = Key('home.session.employee_medium');
  static const sessionAdminHard = Key('home.session.admin_hard');

  static Key session(String id) {
    return switch (id) {
      'guest_easy' => sessionGuestEasy,
      'employee_medium' => sessionEmployeeMedium,
      'admin_hard' => sessionAdminHard,
      _ => Key('home.session.$id'),
    };
  }
}
