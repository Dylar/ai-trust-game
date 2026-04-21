import 'package:flutter_test/flutter_test.dart';
import 'home_test_context.dart';

void main() {
  testWidgets('shows the home screen with a start action and an empty list', (
    tester,
  ) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When

    // Then
    context.screenBot.expectScreenVisible();
    context.screenBot.expectStartSessionVisible();
    context.screenBot.expectEmptySessionsVisible();
  });

  testWidgets('navigates from home to session start', (tester) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.process.openSessionStart();

    // Then
    context.sessionStartBot.expectScreenVisible();
  });

  testWidgets('returns to home with a newly prepared session in the list', (
    tester,
  ) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.process.createAdminHardSessionFromHome();

    // Then
    context.screenBot.expectScreenVisible();
    context.screenBot.expectRecentSessionsVisible();
    context.screenBot.expectRecentSessionCount(1);
  });
}
