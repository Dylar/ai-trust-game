import 'package:flutter/material.dart';

abstract final class LoginKeys {
  static const screen = Key('login.screen');
  static const loadedUsersSection = Key('login.loaded_users_section');
  static const unloadedUsersSection = Key('login.unloaded_users_section');
  static const emptyLoadedUsersState = Key('login.empty_loaded_users_state');
  static const emptyUnloadedUsersState = Key(
    'login.empty_unloaded_users_state',
  );
  static const displayNameInput = Key('login.display_name_input');
  static const createUserButton = Key('login.create_user_button');
  static const loadingIndicator = Key('login.loading_indicator');
  static const errorMessage = Key('login.error_message');

  static ValueKey<String> user(String id) {
    return ValueKey<String>('login.user.$id');
  }
}
