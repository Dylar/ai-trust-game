import 'package:app/core/user/user_profile.dart';

enum LoginScreenStatus { loading, ready, loadUser, loggedIn }

enum LoginError {
  emptyDisplayName,
  loadUsersFailed,
  selectUserFailed,
  createUserFailed,
}

class LoginScreenState {
  const LoginScreenState({
    required this.status,
    required this.loadedUsers,
    required this.unloadedUsers,
    this.error,
  });

  factory LoginScreenState.initial() {
    return LoginScreenState(
      status: LoginScreenStatus.loading,
      loadedUsers: [],
      unloadedUsers: [],
    );
  }

  final LoginScreenStatus status;
  final List<UserProfile> loadedUsers;
  final List<UserProfile> unloadedUsers;
  final LoginError? error;

  bool get isSubmitting => status == LoginScreenStatus.loadUser;

  LoginScreenState copyWith({
    LoginScreenStatus? status,
    List<UserProfile>? loadedUsers,
    List<UserProfile>? unloadedUsers,
    LoginError? error,
    bool clearError = false,
  }) {
    return LoginScreenState(
      status: status ?? this.status,
      loadedUsers: loadedUsers ?? this.loadedUsers,
      unloadedUsers: unloadedUsers ?? this.unloadedUsers,
      error: clearError ? null : error ?? this.error,
    );
  }
}
