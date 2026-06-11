import 'package:flutter/foundation.dart';

import 'user_profile.dart';

class SelectedUserController extends ValueNotifier<UserProfile?> {
  SelectedUserController({UserProfile? initialUser}) : super(initialUser);

  UserProfile get requiredUser {
    final user = value;
    if (user == null) {
      throw StateError('No user selected.');
    }
    return user;
  }

  void select(UserProfile user) {
    value = user;
  }

  void clear() {
    value = null;
  }
}
