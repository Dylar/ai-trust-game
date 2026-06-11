import 'package:flutter/foundation.dart';

import 'user_identity.dart';

class SelectedUserController extends ValueNotifier<UserIdentity?> {
  SelectedUserController({UserIdentity? initialUser}) : super(initialUser);

  UserIdentity get requiredUser {
    final user = value;
    if (user == null) {
      throw StateError('No user selected.');
    }
    return user;
  }

  void select(UserIdentity user) {
    value = user;
  }

  void clear() {
    value = null;
  }
}
