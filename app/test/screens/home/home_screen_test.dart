import 'package:flutter_test/flutter_test.dart';

import '../session_start/session_start_screen_bot.dart';
import 'home_test_context.dart';

void main() {
  testWidgets('shows the home screen with a start action and recent sessions', (
    tester,
  ) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When

    // Then
    context.screenBot.expectScreenVisible();
    context.screenBot.expectStartSessionVisible();
    context.screenBot.expectRecentSessionsVisible();
  });

  testWidgets('navigates from home to session start', (tester) async {
    final context = HomeTestContext(tester);
    final sessionStartBot = SessionStartScreenBot(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.screenBot.tapStartSession();
    await context.baseBot.pump(const Duration(milliseconds: 1));

    // Then
    sessionStartBot.expectScreenVisible();
  });
}
