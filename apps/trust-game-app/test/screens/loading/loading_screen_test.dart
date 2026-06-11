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

  testWidgets(
    'GIVEN retryable loading result WHEN shown THEN displays retry without calling onLoaded',
    (tester) async {
      StartupRefreshResult? loadedResult;
      final service = _FakeStartupRefreshService(
        result: const StartupRefreshResult(
          status: StartupRefreshStatus.offlineFallback,
          refreshedUserCount: 0,
          refreshedSessionCount: 0,
          failedUserIds: <String>['user-1'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingScreen(
            viewModel: LoadingViewModel(
              startupRefreshService: service,
              minimumDisplayDuration: Duration.zero,
            ),
            onLoaded: (result) {
              loadedResult = result;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(LoadingKeys.retryButton), findsOneWidget);
      expect(find.text('Offline mode uses saved data'), findsOneWidget);
      expect(loadedResult, isNull);
    },
  );

  testWidgets(
    'GIVEN retryable loading result WHEN retry succeeds THEN calls onLoaded',
    (tester) async {
      StartupRefreshResult? loadedResult;
      final service = _SequencedStartupRefreshService(
        results: const <StartupRefreshResult>[
          StartupRefreshResult(
            status: StartupRefreshStatus.partialFailure,
            refreshedUserCount: 1,
            refreshedSessionCount: 1,
            failedUserIds: <String>['user-2'],
          ),
          StartupRefreshResult(
            status: StartupRefreshStatus.refreshed,
            refreshedUserCount: 2,
            refreshedSessionCount: 3,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingScreen(
            viewModel: LoadingViewModel(
              startupRefreshService: service,
              minimumDisplayDuration: Duration.zero,
            ),
            onLoaded: (result) {
              loadedResult = result;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(LoadingKeys.retryButton));
      await tester.pumpAndSettle();

      expect(find.byKey(LoadingKeys.retryButton), findsNothing);
      expect(loadedResult?.status, StartupRefreshStatus.refreshed);
      expect(service.calls, 2);
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

class _SequencedStartupRefreshService implements StartupRefreshService {
  _SequencedStartupRefreshService({required this.results});

  final List<StartupRefreshResult> results;
  int calls = 0;

  @override
  Future<StartupRefreshResult> refreshKnownUsers() async {
    final index = calls;
    calls += 1;
    return results[index];
  }
}
