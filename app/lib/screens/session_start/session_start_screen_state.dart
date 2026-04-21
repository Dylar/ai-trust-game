import '../../models/session_models.dart';

enum SessionStartStatus { idle, loading, prepared, error }

enum SessionStartError { unexpected }

class SessionStartScreenState {
  const SessionStartScreenState({
    required this.selectedRole,
    required this.selectedMode,
    required this.status,
    required this.error,
    required this.createdSessionId,
  });

  factory SessionStartScreenState.initial() {
    return const SessionStartScreenState(
      selectedRole: Role.guest,
      selectedMode: Mode.easy,
      status: SessionStartStatus.idle,
      error: null,
      createdSessionId: null,
    );
  }

  final Role selectedRole;
  final Mode selectedMode;
  final SessionStartStatus status;
  final SessionStartError? error;
  final String? createdSessionId;

  bool get isSubmitting => status == SessionStartStatus.loading;

  SessionStartScreenState copyWith({
    Role? selectedRole,
    Mode? selectedMode,
    SessionStartStatus? status,
    SessionStartError? error,
    String? createdSessionId,
    bool resetStatus = false,
  }) {
    return SessionStartScreenState(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedMode: selectedMode ?? this.selectedMode,
      status: resetStatus ? SessionStartStatus.idle : status ?? this.status,
      error: resetStatus ? null : error ?? this.error,
      createdSessionId: resetStatus
          ? null
          : createdSessionId ?? this.createdSessionId,
    );
  }
}
