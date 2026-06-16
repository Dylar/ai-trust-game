import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/sync_service.dart';
import 'package:app/screens/loading/loading_keys.dart';
import 'package:app/screens/loading/loading_screen.dart';
import 'package:app/screens/loading/loading_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  testWidgets(
    'GIVEN loading screen WHEN loading completes THEN waits at least one second and opens login',
    (tester) async {
      var openedLogin = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              openedLogin = true;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const SizedBox.shrink(),
              );
            }
            return null;
          },
          home: LoadingScreen(
            viewModel: LoadingViewModel(
              appLogger: _silentLogger,
              authService: _FakeAuthService(),
              syncService: _FakeSyncService(),
            ),
          ),
        ),
      );

      expect(find.byKey(LoadingKeys.loadingIndicator), findsOneWidget);
      final context = tester.element(find.byKey(LoadingKeys.screen));
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.loadingUserProfilesStep), findsOneWidget);
      expect(find.text(l10n.loadingSyncSavedUsersStep), findsOneWidget);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 999));

      expect(find.byKey(LoadingKeys.loadingIndicator), findsOneWidget);
      expect(openedLogin, isFalse);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(openedLogin, isTrue);
    },
  );

  testWidgets(
    'GIVEN loading failure WHEN loading screen opens THEN logs and shows retry',
    (tester) async {
      final sink = RecordingAppLogSink();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoadingScreen(
            viewModel: LoadingViewModel(
              appLogger: AppLogger(sinks: <AppLogSink>[sink]),
              authService: _FakeAuthService(shouldFailLoad: true),
              syncService: _FakeSyncService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(LoadingKeys.retryButton), findsOneWidget);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'loading');
      expect(sink.events.single.message, 'Startup loading failed');
      expect(sink.events.single.attributes['step'], 'loadUserProfiles');
    },
  );
}

class _FakeAuthService implements AuthService {
  const _FakeAuthService({this.shouldFailLoad = false});

  final bool shouldFailLoad;

  @override
  Future<UserProfile> createUser(String displayName) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadUserProfiles() async {
    if (shouldFailLoad) {
      throw Exception('load failed');
    }
  }

  @override
  void selectUser(UserProfile user) {}
}

class _FakeSyncService implements SyncService {
  @override
  Future<SyncResult> syncStartup() async {
    return const SyncResult.synced();
  }

  @override
  Future<SyncResult> syncUserRestore(UserProfile user) {
    throw UnimplementedError();
  }
}

const _silentLogger = AppLogger(sinks: <AppLogSink>[]);
