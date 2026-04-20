import 'package:app/screens/session_start/session_start_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class SessionStartScreenBot extends BaseScreenBot {
  SessionStartScreenBot(super.tester);

  Future<void> selectAdminRole() async {
    await tap(SessionStartKeys.roleAdmin);
  }

  Future<void> selectHardMode() async {
    await scrollUntilVisible(SessionStartKeys.modeHard);
    await tap(SessionStartKeys.modeHard);
  }

  Future<void> tapPrepareSession() async {
    await scrollUntilVisible(SessionStartKeys.prepareButton);
    await tap(SessionStartKeys.prepareButton);
  }

  void expectScreenVisible() {
    expect(isVisible(SessionStartKeys.screen), isTrue);
    expect(isVisible(SessionStartKeys.title), isTrue);
  }

  void expectGuestRoleSelected() {
    expect(_roleChip(SessionStartKeys.roleGuest).selected, isTrue);
    expect(_roleChip(SessionStartKeys.roleAdmin).selected, isFalse);
  }

  void expectEasyModeSelected() {
    expect(
      _modeIndicator(SessionStartKeys.modeEasyIndicator).icon,
      Icons.radio_button_checked,
    );
    expect(
      _modeIndicator(SessionStartKeys.modeHardIndicator).icon,
      Icons.radio_button_off,
    );
  }

  void expectPrepareButtonEnabled() {
    expect(_filledButton().onPressed, isNotNull);
  }

  void expectPrepareButtonDisabled() {
    expect(_filledButton().onPressed, isNull);
  }

  void expectPreparedStatusVisible() {
    expect(isVisible(SessionStartKeys.statusCard), isTrue);
  }

  void expectPreparedStatusTextShown() {
    expect(find.textContaining('Prepared'), findsOneWidget);
  }

  ChoiceChip _roleChip(Key key) {
    return tester.widget<ChoiceChip>(find.byKey(key));
  }

  Icon _modeIndicator(Key key) {
    return tester.widget<Icon>(find.byKey(key));
  }

  FilledButton _filledButton() {
    return tester.widget<FilledButton>(
      find.byKey(SessionStartKeys.prepareButton),
    );
  }
}
