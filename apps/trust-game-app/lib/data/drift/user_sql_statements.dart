import 'package:app/data/drift/drift_db.dart';

class UserSqlStatements {
  const UserSqlStatements({required this.database});

  final DriftDB database;

  Future<List<UserRow>> listUsers() {
    return database.select(database.userRows).get();
  }

  Future<Map<String, DateTime>> latestActivityByUserId() async {
    final rows = await database.customSelect(_latestActivityByUserSql).get();

    return <String, DateTime>{
      for (final row in rows)
        row.read<String>('user_id'): row.read<DateTime>('last_activity_at'),
    };
  }
}

const _latestActivityByUserSql = '''
SELECT user_id, MAX(activity_at) AS last_activity_at
FROM (
  SELECT user_id, updated_at AS activity_at FROM sessions
  UNION ALL
  SELECT user_id, saved_at AS activity_at FROM interactions
)
GROUP BY user_id
''';
