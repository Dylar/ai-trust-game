enum SessionRole { guest, employee, admin }

enum SessionMode { easy, medium, hard }

enum SessionStartStatus { idle, prepared }

class SessionStartScreenState {
  const SessionStartScreenState({
    required this.selectedRole,
    required this.selectedMode,
    required this.isSubmitting,
    required this.status,
  });

  factory SessionStartScreenState.initial() {
    return const SessionStartScreenState(
      selectedRole: SessionRole.guest,
      selectedMode: SessionMode.easy,
      isSubmitting: false,
      status: SessionStartStatus.idle,
    );
  }

  final SessionRole selectedRole;
  final SessionMode selectedMode;
  final bool isSubmitting;
  final SessionStartStatus status;

  SessionStartScreenState copyWith({
    SessionRole? selectedRole,
    SessionMode? selectedMode,
    bool? isSubmitting,
    SessionStartStatus? status,
    bool resetStatus = false,
  }) {
    return SessionStartScreenState(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedMode: selectedMode ?? this.selectedMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      status: resetStatus ? SessionStartStatus.idle : status ?? this.status,
    );
  }
}
