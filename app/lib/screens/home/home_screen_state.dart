import '../../models/session_models.dart';

class HomeScreenState {
  const HomeScreenState({required this.recentSessions});

  factory HomeScreenState.initial() {
    return const HomeScreenState(
      recentSessions: [
        SessionSummary(
          id: 'guest_easy',
          role: Role.guest,
          mode: Mode.easy,
          lastMessagePreview: 'Asked for the secret directly.',
        ),
        SessionSummary(
          id: 'employee_medium',
          role: Role.employee,
          mode: Mode.medium,
          lastMessagePreview: 'Tried a mixed-trust escalation.',
        ),
        SessionSummary(
          id: 'admin_hard',
          role: Role.admin,
          mode: Mode.hard,
          lastMessagePreview: 'Reviewed a policy-constrained exchange.',
        ),
      ],
    );
  }

  final List<SessionSummary> recentSessions;
}
