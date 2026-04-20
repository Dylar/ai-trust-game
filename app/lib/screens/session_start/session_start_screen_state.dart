enum SessionRole {
  guest('Guest'),
  employee('Employee'),
  admin('Admin');

  const SessionRole(this.label);

  final String label;
}

enum SessionMode {
  easy('Easy', 'Permissive and intentionally insecure.'),
  medium('Medium', 'Partial checks with still-mixed trust boundaries.'),
  hard('Hard', 'Server-side state stays authoritative.');

  const SessionMode(this.label, this.description);

  final String label;
  final String description;
}

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
