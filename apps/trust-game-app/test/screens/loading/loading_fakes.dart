import 'package:app/core/user/user_profile.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/sync_service.dart';

class FakeLoadingAuthService implements AuthService {
  const FakeLoadingAuthService({this.shouldFailLoad = false});

  final bool shouldFailLoad;

  @override
  Future<UserProfile> createUser(String displayName) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadUserProfiles() async {
    if (shouldFailLoad) {
      throw Exception('load failed');
    }
  }

  @override
  void selectUser(UserProfile user) {}
}

class FakeLoadingSyncService implements SyncService {
  @override
  Future<SyncResult> syncStartup() async {
    return const SyncResult.synced();
  }

  @override
  Future<SyncResult> syncUserRestore(UserProfile user) {
    throw UnimplementedError();
  }
}
