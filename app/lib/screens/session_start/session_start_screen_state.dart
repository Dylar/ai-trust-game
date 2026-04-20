enum SessionRole { guest, employee, admin }

enum SessionMode { easy, medium, hard }

enum SessionStartStatus { idle, loading, prepared, error }

enum SessionStartError { unexpected }

class SessionStartScreenState {
  const SessionStartScreenState({
    required this.selectedRole,
    required this.selectedMode,
    required this.status,
    required this.error,
  });

  factory SessionStartScreenState.initial() {
    return const SessionStartScreenState(
      selectedRole: SessionRole.guest,
      selectedMode: SessionMode.easy,
      status: SessionStartStatus.idle,
      error: null,
    );
  }

  final SessionRole selectedRole;
  final SessionMode selectedMode;
  final SessionStartStatus status;
  final SessionStartError? error;

  bool get isSubmitting => status == SessionStartStatus.loading;

  SessionStartScreenState copyWith({
    SessionRole? selectedRole,
    SessionMode? selectedMode,
    SessionStartStatus? status,
    SessionStartError? error,
    bool resetStatus = false,
  }) {
    return SessionStartScreenState(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedMode: selectedMode ?? this.selectedMode,
      status: resetStatus ? SessionStartStatus.idle : status ?? this.status,
      error: resetStatus ? null : error ?? this.error,
    );
  }
}
