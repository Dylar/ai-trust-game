import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../testing/mocks/backend_mock_client.dart';

class FailingSessionRepository implements SessionRepository {
  final ValueNotifier<List<Session>> _sessions = ValueNotifier<List<Session>>(
    const <Session>[],
  );

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async {
    throw Exception('load failed');
  }

  @override
  Future<List<Session>> listSessions() async {
    return const <Session>[];
  }

  @override
  Future<void> saveSession(Session session) async {}
}

http.Client interactionFailureClient({required int statusCode}) {
  return buildBackendMockClient(
    override: (request) async {
      if (request.url.path == '/interaction') {
        return http.Response('', statusCode);
      }

      return null;
    },
  );
}

http.Client offlineInteractionClient() {
  return buildBackendMockClient(
    override: (request) async {
      if (request.url.path == '/interaction') {
        throw http.ClientException('offline');
      }

      return null;
    },
  );
}
