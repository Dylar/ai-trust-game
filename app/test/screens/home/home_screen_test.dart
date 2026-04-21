import 'package:flutter_test/flutter_test.dart';

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
}
