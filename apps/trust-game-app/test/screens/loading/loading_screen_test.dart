import 'package:app/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/recording_app_log_sink.dart';
import 'loading_fakes.dart';
import 'loading_test_context.dart';

void main() {
  testWidgets(
    'GIVEN loading screen WHEN loading completes THEN waits at least one second and opens login',
    (tester) async {
      final context = LoadingTestContext(tester);

      // Given
      await context.process.startLoadingScreen();

      // When
      context.screenBot.expectLoadingVisible();
      context.screenBot.expectLoadingStepsVisible();
      await context.process.waitJustBeforeMinimumDisplayDuration();

      // Then
      context.screenBot.expectLoadingVisible();

      // When
      await context.process.finishMinimumDisplayDuration();

      // Then
      context.screenBot.expectLoginVisible();
    },
  );

  testWidgets(
    'GIVEN loading failure WHEN loading screen opens THEN logs and shows retry',
    (tester) async {
      final sink = RecordingAppLogSink();
      final context = LoadingTestContext(
        tester,
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        authApi: const FakeLoadingAuthApi(shouldFailLoad: true),
      );

      // Given
      await context.process.startLoadingScreen();

      // When
      await context.process.waitUntilRetryVisible();

      // Then
      context.screenBot.expectRetryVisible();
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'loading');
      expect(sink.events.single.message, 'Startup loading failed');
      expect(sink.events.single.attributes['step'], 'loadUserProfiles');
    },
  );
}
