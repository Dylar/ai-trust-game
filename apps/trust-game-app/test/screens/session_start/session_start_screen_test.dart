import 'package:flutter_test/flutter_test.dart';
import 'session_start_test_context.dart';

void main() {
  testWidgets('shows the default session start state', (tester) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.process.startSessionStartScreen();

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
    await context.process.startSessionStartScreen();

    // When
    await context.screenBot.tapPrepareSession();

    // Then
    context.screenBot.expectPrepareButtonLoading();
    await context.process.waitUntilPreparationFinished();
  });

  testWidgets('does not show prepared feedback after session preparation', (
    tester,
  ) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.process.startSessionStartScreen();

    // When
    await context.process.prepareAdminHardSession();

    // Then
    context.screenBot.expectPreparedFeedbackHidden();
  });

  testWidgets('opens a dialog when preparing a session fails', (tester) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.process.startWithSessionStartFailure(statusCode: 500);

    // When
    await context.process.prepareSessionExpectingDialog();

    // Then
    context.screenBot.expectErrorDialogVisible();
  });

  testWidgets('opens a dialog when preparing a session is offline', (
    tester,
  ) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.process.startWithOfflineSessionStart();

    // When
    await context.process.prepareSessionExpectingDialog();

    // Then
    context.screenBot.expectErrorDialogVisible();
  });
}
