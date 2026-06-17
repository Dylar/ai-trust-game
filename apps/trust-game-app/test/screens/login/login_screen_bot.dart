import 'package:app/screens/home/home_keys.dart';
import 'package:app/screens/login/login_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class LoginScreenBot extends BaseScreenBot {
  LoginScreenBot(super.tester);

  void expectScreenVisible() {
    expect(isVisible(LoginKeys.screen), isTrue);
  }

  void expectLoadedUsersVisible() {
    expect(isVisible(LoginKeys.loadedUsersSection), isTrue);
  }

  void expectUnloadedUsersVisible() {
    expect(isVisible(LoginKeys.unloadedUsersSection), isTrue);
  }

  void expectUserVisible(String userId) {
    expect(isVisible(LoginKeys.user(userId)), isTrue);
  }

  void expectHomeVisible() {
    expect(isVisible(HomeKeys.screen), isTrue);
  }

  void expectSelectedUserLoadErrorVisible() {
    expect(find.text('The selected user could not be loaded.'), findsOneWidget);
  }

  void expectEmptyDisplayNameErrorVisible() {
    expect(
      find.text('Enter a display name before creating a user.'),
      findsOneWidget,
    );
  }

  void expectCreateUserErrorVisible() {
    expect(
      find.text('The backend is not reachable or rejected the new user.'),
      findsOneWidget,
    );
  }

  Future<void> selectUser(String userId) async {
    await tap(LoginKeys.user(userId));
  }

  Future<void> enterDisplayName(String displayName) async {
    await enterText(LoginKeys.displayNameInput, displayName);
  }

  Future<void> tapCreateUser() async {
    await tap(LoginKeys.createUserButton);
  }
}
