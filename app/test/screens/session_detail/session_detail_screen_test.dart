import 'dart:convert';

import 'package:app/screens/session_detail/session_detail_keys.dart';
import 'package:app/screens/session_detail/session_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../testing/test_dependencies.dart';
import 'session_detail_test_context.dart';

void main() {
  testWidgets('shows session analysis from the backend', (tester) async {
    final context = SessionDetailTestContext(tester);

    await context.appBot.startApp(
      home: const SessionDetailScreen(sessionId: 'local-admin-hard'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(SessionDetailKeys.screen), findsOneWidget);
    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'clean',
    );
  });

  testWidgets('shows backend error text when session analysis loading fails', (
    tester,
  ) async {
    final context = SessionDetailTestContext(tester);
    final dependencies = buildTestDependencies(
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode(<String, Object>{
            'error': <String, String>{'code': 'session_analysis_not_found'},
          }),
          404,
        ),
      ),
    );

    await context.appBot.startApp(
      home: const SessionDetailScreen(sessionId: 'local-admin-hard'),
      dependencies: dependencies,
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(SessionDetailKeys.errorState), findsOneWidget);
    expect(
      find.text('No analysis is available for this session yet.'),
      findsOneWidget,
    );
    expect(find.text('HTTP status: 404'), findsOneWidget);
  });
}
