import 'package:app/core/user/user_profile.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/sync_service.dart';

import '../../testing/test_user_profile.dart';

class FakeLoginAuthService implements AuthService {
  FakeLoginAuthService({this.shouldFailCreate = false});

  final bool shouldFailCreate;
  UserProfile? selectedUser;
  String? createdDisplayName;

  @override
  Future<void> loadUserProfiles() async {}

  @override
  void selectUser(UserProfile user) {
    selectedUser = user;
  }

  @override
  Future<UserProfile> createUser(String displayName) async {
    if (shouldFailCreate) {
      throw Exception('create failed');
    }
    createdDisplayName = displayName;
    final user = UserProfile(
      id: 'created-user',
      displayName: displayName,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    selectedUser = user;
    return user;
  }
}

class FakeLoginUserRepository implements UserRepository {
  const FakeLoginUserRepository({
    this.loadedUsers = const <UserProfile>[],
    this.unloadedUsers = const <UserProfile>[],
  });

  final List<UserProfile> loadedUsers;
  final List<UserProfile> unloadedUsers;

  @override
  Future<List<UserProfile>> listLoadedUsers() async => loadedUsers;

  @override
  Future<List<UserProfile>> listUnloadedUsers() async => unloadedUsers;

  @override
  Future<List<UserProfile>> listUsers() async {
    return <UserProfile>[...loadedUsers, ...unloadedUsers];
  }

  @override
  Future<void> saveUser(UserProfile user) async {}
}

class FakeLoginSyncService implements SyncService {
  FakeLoginSyncService({
    this.shouldFailSyncUser = false,
    this.syncUserStatus = SyncStatus.synced,
  });

  final bool shouldFailSyncUser;
  final SyncStatus syncUserStatus;
  UserProfile? syncedUser;

  @override
  Future<SyncResult> syncStartup() async {
    return const SyncResult.synced();
  }

  @override
  Future<SyncResult> syncUserRestore(UserProfile user) async {
    syncedUser = user;
    if (shouldFailSyncUser) {
      throw Exception('sync failed');
    }
    return switch (syncUserStatus) {
      SyncStatus.synced => const SyncResult.synced(),
      SyncStatus.failed => const SyncResult.failed(),
    };
  }
}

UserProfile loadedLoginUserProfile(String id) {
  return UserProfile(
    id: id,
    displayName: id,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    lastActivityAt: DateTime.utc(2026),
  );
}

UserProfile unloadedLoginUserProfile(String id) {
  return testUserProfile(id);
}
