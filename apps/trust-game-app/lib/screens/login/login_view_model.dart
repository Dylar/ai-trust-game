import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/screens/login/login_logger.dart';
import 'package:app/screens/login/login_screen_state.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/sync_service.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel {
  LoginViewModel({
    required AppLogger appLogger,
    required AuthService authService,
    required UserRepository userRepository,
    required SyncService syncService,
  }) : _userRepository = userRepository,
       _authService = authService,
       _syncService = syncService,
       _logger = LoginLogger(appLogger: appLogger),
       stateNotifier = ValueNotifier<LoginScreenState>(
         LoginScreenState.initial(),
       );

  final LoginLogger _logger;
  final AuthService _authService;
  final SyncService _syncService;
  final UserRepository _userRepository;

  final ValueNotifier<LoginScreenState> stateNotifier;

  LoginScreenState get state => stateNotifier.value;

  void dispose() {
    stateNotifier.dispose();
  }

  Future<void> init() async {
    try {
      final loadedUsers = await _userRepository.listLoadedUsers();
      final unloadedUsers = await _userRepository.listUnloadedUsers();
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.ready,
        loadedUsers: loadedUsers,
        unloadedUsers: unloadedUsers,
      );
    } on Exception catch (error, stackTrace) {
      await _logger.logUserListLoadFailed(error: error, stackTrace: stackTrace);
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.ready,
        error: LoginError.loadUsersFailed,
      );
    }
  }

  Future<void> selectUser(UserProfile user) async {
    stateNotifier.value = stateNotifier.value.copyWith(
      status: LoginScreenStatus.loadUser,
    );
    try {
      await _syncService.syncUser(user);
      _authService.selectUser(user);
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.loggedIn,
      );
    } on Object catch (error, stackTrace) {
      await _logger.logUserSelectionFailed(
        user: user,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.ready,
        error: LoginError.selectUserFailed,
      );
    }
  }

  Future<void> createUser(String displayName) async {
    final trimmedDisplayName = displayName.trim();
    if (trimmedDisplayName.isEmpty) {
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.ready,
        error: LoginError.emptyDisplayName,
      );
      return;
    }

    stateNotifier.value = stateNotifier.value.copyWith(
      status: LoginScreenStatus.loadUser,
      clearError: true,
    );
    try {
      await _authService.createUser(trimmedDisplayName);
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.loggedIn,
      );
    } on Exception catch (error, stackTrace) {
      await _logger.logUserCreationFailed(
        displayName: trimmedDisplayName,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = stateNotifier.value.copyWith(
        status: LoginScreenStatus.ready,
        error: LoginError.createUserFailed,
      );
    }
  }

  void clearError() {
    stateNotifier.value = state.copyWith(clearError: true);
  }
}
