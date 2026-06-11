import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/auth/auth_api_client.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/services/auth_logger.dart';

abstract interface class AuthService {
  Future<UserProfile> createUser(String displayName);

  Future<void> loadUserProfiles();

  void selectUser(UserProfile user);
}

class AuthServiceImpl implements AuthService {
  AuthServiceImpl({
    required AppLogger appLogger,
    required UserRepository userRepository,
    required SelectedUserController selectedUser,
    AuthApiClient? apiClient,
  }) : _userRepository = userRepository,
       _selectedUser = selectedUser,
       _logger = AuthLogger(appLogger: appLogger),
       _apiClient = apiClient;

  final UserRepository _userRepository;
  final SelectedUserController _selectedUser;
  final AuthLogger _logger;
  final AuthApiClient? _apiClient;

  @override
  Future<UserProfile> createUser(String displayName) async {
    final trimmedDisplayName = displayName.trim();
    final apiClient = _apiClient;
    if (apiClient == null) {
      throw const ApiException(
        error: ApiError(code: ApiErrorCode.backendUnreachable),
      );
    }

    final user = await apiClient.createUser(trimmedDisplayName);
    await _userRepository.saveUser(user);
    _selectedUser.select(user);
    return user;
  }

  @override
  Future<void> loadUserProfiles() async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return;
    }

    try {
      final users = await apiClient.listUsers();
      for (final user in users) {
        await _userRepository.saveUser(user);
      }
    } on ApiException catch (error, stackTrace) {
      await _logger.logUserProfileLoadFallback(
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
  }

  @override
  void selectUser(UserProfile user) {
    _selectedUser.select(user);
  }
}
