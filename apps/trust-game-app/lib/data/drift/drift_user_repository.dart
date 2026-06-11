import 'package:app/core/user/user_profile.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/drift/user_sql_statements.dart';

abstract interface class UserRepository {
  Future<List<UserProfile>> listUsers();

  Future<List<UserProfile>> listLoadedUsers();

  Future<List<UserProfile>> listUnloadedUsers();

  Future<void> saveUser(UserProfile user);
}

class DriftUserRepository implements UserRepository {
  DriftUserRepository({required this.database})
    : statements = UserSqlStatements(database: database);

  final DriftDB database;
  final UserSqlStatements statements;

  @override
  Future<List<UserProfile>> listUsers() async {
    return await _listUsersWithActivity();
  }

  @override
  Future<List<UserProfile>> listLoadedUsers() async {
    final users = await _listUsersWithActivity();
    final loaded = users.where((user) => user.isLoaded).toList();
    loaded.sort(_compareByLatestActivity);
    return loaded;
  }

  @override
  Future<List<UserProfile>> listUnloadedUsers() async {
    final users = await _listUsersWithActivity();
    final unloaded = users.where((user) => !user.isLoaded).toList();
    unloaded.sort(_compareAlphabetically);
    return unloaded;
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    await database
        .into(database.userRows)
        .insertOnConflictUpdate(
          UserRowsCompanion.insert(
            id: user.id,
            displayName: user.displayName,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          ),
        );
  }

  Future<List<UserProfile>> _listUsersWithActivity() async {
    final rows = await statements.listUsers();
    final activityByUserId = await statements.latestActivityByUserId();
    return rows
        .map((row) => _toUserProfile(row, activityByUserId[row.id]))
        .toList();
  }
}

UserProfile _toUserProfile(UserRow row, DateTime? lastActivityAt) {
  return UserProfile(
    id: row.id,
    displayName: row.displayName,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastActivityAt: lastActivityAt,
  );
}

int _compareByLatestActivity(UserProfile a, UserProfile b) {
  return b.lastActivityAt!.compareTo(a.lastActivityAt!);
}

int _compareAlphabetically(UserProfile a, UserProfile b) {
  final byDisplayName = a.displayName.compareTo(b.displayName);
  if (byDisplayName != 0) {
    return byDisplayName;
  }
  return a.id.compareTo(b.id);
}
