import 'package:drift/drift.dart';

import 'package:app/data/local/local_database.dart';

class KnownUser {
  const KnownUser({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.lastSelectedAt,
    this.isLoaded = false,
  });

  final String id;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSelectedAt;
  final bool isLoaded;
}

abstract interface class LocalUserRepository {
  Future<List<KnownUser>> listUsers();

  Future<List<KnownUser>> listLoadedUsers();

  Future<List<KnownUser>> listUnloadedUsers();

  Future<KnownUser?> getSelectedUser();

  Future<void> saveKnownUser(KnownUser user);

  Future<void> selectUser(String userId);
}

class DriftLocalUserRepository implements LocalUserRepository {
  const DriftLocalUserRepository({required this.database});

  final LocalDatabase database;

  @override
  Future<List<KnownUser>> listUsers() async {
    final rows = await database.select(database.userProfiles).get();
    final loadedUserIds = await _loadedUserIds();
    final users = rows
        .map((row) => _toKnownUser(row, loadedUserIds.contains(row.id)))
        .toList();
    users.sort(_compareByLastSelected);
    return users;
  }

  @override
  Future<List<KnownUser>> listLoadedUsers() async {
    final users = await listUsers();
    return users.where((user) => user.isLoaded).toList();
  }

  @override
  Future<List<KnownUser>> listUnloadedUsers() async {
    final users = await listUsers();
    return users.where((user) => !user.isLoaded).toList();
  }

  @override
  Future<KnownUser?> getSelectedUser() async {
    final selected = await database
        .select(database.selectedUsers)
        .getSingleOrNull();
    if (selected == null) {
      return null;
    }

    final user = await (database.select(
      database.userProfiles,
    )..where((tbl) => tbl.id.equals(selected.userId))).getSingleOrNull();
    if (user == null) {
      return null;
    }

    final loadedUserIds = await _loadedUserIds();
    return _toKnownUser(user, loadedUserIds.contains(user.id));
  }

  @override
  Future<void> saveKnownUser(KnownUser user) async {
    await database
        .into(database.userProfiles)
        .insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: user.id,
            displayName: user.displayName,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
            lastSelectedAt: Value(user.lastSelectedAt),
          ),
        );
  }

  @override
  Future<void> selectUser(String userId) async {
    final now = DateTime.now().toUtc();
    await database.transaction(() async {
      await (database.update(
        database.userProfiles,
      )..where((tbl) => tbl.id.equals(userId))).write(
        UserProfilesCompanion(
          lastSelectedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await database
          .into(database.selectedUsers)
          .insertOnConflictUpdate(
            SelectedUsersCompanion.insert(
              id: const Value(0),
              userId: userId,
              selectedAt: now,
            ),
          );
    });
  }

  Future<Set<String>> _loadedUserIds() async {
    final rows = await database
        .customSelect('SELECT DISTINCT user_id FROM sessions')
        .get();
    return rows.map((row) => row.read<String>('user_id')).toSet();
  }
}

KnownUser _toKnownUser(UserProfile row, bool isLoaded) {
  return KnownUser(
    id: row.id,
    displayName: row.displayName,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastSelectedAt: row.lastSelectedAt,
    isLoaded: isLoaded,
  );
}

int _compareByLastSelected(KnownUser a, KnownUser b) {
  final aSelected = a.lastSelectedAt;
  final bSelected = b.lastSelectedAt;
  if (aSelected == null && bSelected == null) {
    return a.displayName.compareTo(b.displayName);
  }
  if (aSelected == null) {
    return 1;
  }
  if (bSelected == null) {
    return -1;
  }
  return bSelected.compareTo(aSelected);
}
