import 'package:app/screens/loading/loading_keys.dart';
import 'package:app/screens/loading/loading_screen.dart';
import 'package:app/screens/loading/loading_view_model.dart';
import 'package:app/services/startup_refresh_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'GIVEN loading screen WHEN loading completes THEN waits at least one second and calls onLoaded',
    (tester) async {
      StartupRefreshResult? loadedResult;
      final service = _FakeStartupRefreshService(
        result: const StartupRefreshResult(
          status: StartupRefreshStatus.refreshed,
          refreshedUserCount: 1,
          refreshedSessionCount: 2,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingScreen(
            viewModel: LoadingViewModel(startupRefreshService: service),
            onLoaded: (result) {
              loadedResult = result;
            },
          ),
        ),
      );

      expect(find.byKey(LoadingKeys.loadingIndicator), findsOneWidget);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 999));

      expect(find.byKey(LoadingKeys.loadingIndicator), findsOneWidget);
      expect(loadedResult, isNull);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.byKey(LoadingKeys.loadingIndicator), findsNothing);
      expect(find.text('Saved users refreshed'), findsOneWidget);
      expect(loadedResult?.status, StartupRefreshStatus.refreshed);
    },
  );
}

class _FakeStartupRefreshService implements StartupRefreshService {
  const _FakeStartupRefreshService({required this.result});

  final StartupRefreshResult result;

  @override
  Future<StartupRefreshResult> refreshKnownUsers() async {
    return result;
  }
}
