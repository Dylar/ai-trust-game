import 'package:flutter_test/flutter_test.dart';

import 'session_start_test_context.dart';

void main() {
  testWidgets('shows the default session start state', (tester) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When

    // Then
    context.screenBot.expectScreenVisible();
    context.screenBot.expectGuestRoleSelected();
    context.screenBot.expectEasyModeSelected();
    context.screenBot.expectPrepareButtonEnabled();
  });

  testWidgets('shows a loading state while preparing a session', (
    tester,
  ) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.screenBot.tapPrepareSession();

    // Then
    context.screenBot.expectLoadingFeedbackVisible();
    await context.process.waitUntilPreparationFinished();
  });

  testWidgets('shows the prepared state after selecting admin and hard', (
    tester,
  ) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.process.prepareAdminHardSession();

    // Then
    context.screenBot.expectPreparedStatusVisible();
    context.screenBot.expectPreparedStatusTextShown();
  });
}
