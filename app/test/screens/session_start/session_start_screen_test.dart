import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/failing_services.dart';
import '../../testing/test_dependencies.dart';
import 'session_start_test_context.dart';

void main() {
  testWidgets('shows the default session start state', (tester) async {
    final context = SessionStartTestContext(tester);

    // Given
    await context.appBot.startApp(
      homeBuilder: (router) => router.buildSessionStartScreen(),
    );

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
    await context.appBot.startApp(
      homeBuilder: (router) => router.buildSessionStartScreen(),
    );

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
    await context.appBot.startApp(
      homeBuilder: (router) => router.buildSessionStartScreen(),
    );

    // When
    await context.process.prepareAdminHardSession();

    // Then
    expect(find.textContaining('Started'), findsNothing);
  });

  testWidgets('opens a dialog when preparing a session fails', (tester) async {
    final context = SessionStartTestContext(tester);
    final dependencies = buildTestDependencies(
      sessionService: const FailingSessionService(),
    );

    // Given
    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) => router.buildSessionStartScreen(),
    );

    // When
    await context.screenBot.tapPrepareSession();
    await tester.pumpAndSettle();

    // Then
    context.screenBot.expectErrorDialogVisible();
  });
}
