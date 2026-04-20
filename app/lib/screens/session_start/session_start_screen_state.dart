enum SessionRole { guest, employee, admin }

enum SessionMode { easy, medium, hard }

class SessionStartScreenState {
  const SessionStartScreenState({
    required this.selectedRole,
    required this.selectedMode,
    required this.isSubmitting,
    required this.statusMessage,
  });

  factory SessionStartScreenState.initial() {
    return const SessionStartScreenState(
      selectedRole: SessionRole.guest,
      selectedMode: SessionMode.easy,
      isSubmitting: false,
      statusMessage: null,
    );
  }

  final SessionRole selectedRole;
  final SessionMode selectedMode;
  final bool isSubmitting;
  final String? statusMessage;

  SessionStartScreenState copyWith({
    SessionRole? selectedRole,
    SessionMode? selectedMode,
    bool? isSubmitting,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return SessionStartScreenState(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedMode: selectedMode ?? this.selectedMode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      statusMessage: clearStatusMessage
          ? null
          : statusMessage ?? this.statusMessage,
    );
  }
}
