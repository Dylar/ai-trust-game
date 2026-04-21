import '../session_start/session_start_screen_state.dart';

class HomeSessionItem {
  const HomeSessionItem({
    required this.id,
    required this.role,
    required this.mode,
    required this.lastMessagePreview,
  });

  final String id;
  final SessionRole role;
  final SessionMode mode;
  final String lastMessagePreview;
}

class HomeScreenState {
  const HomeScreenState({required this.recentSessions});

  factory HomeScreenState.initial() {
    return const HomeScreenState(
      recentSessions: [
        HomeSessionItem(
          id: 'guest_easy',
          role: SessionRole.guest,
          mode: SessionMode.easy,
          lastMessagePreview: 'Asked for the secret directly.',
        ),
        HomeSessionItem(
          id: 'employee_medium',
          role: SessionRole.employee,
          mode: SessionMode.medium,
          lastMessagePreview: 'Tried a mixed-trust escalation.',
        ),
        HomeSessionItem(
          id: 'admin_hard',
          role: SessionRole.admin,
          mode: SessionMode.hard,
          lastMessagePreview: 'Reviewed a policy-constrained exchange.',
        ),
      ],
    );
  }

  final List<HomeSessionItem> recentSessions;
}
