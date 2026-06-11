import 'package:app/core/user/user_profile.dart';

UserProfile testUserProfile(String id) {
  return UserProfile(
    id: id,
    displayName: id,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}
