import 'package:http/http.dart' as http;

import '../../testing/mocks/backend_mock_client.dart';

http.Client sessionStartFailureClient({required int statusCode}) {
  return buildBackendMockClient(
    override: (request) async {
      if (request.url.path == '/session/start') {
        return http.Response('', statusCode);
      }

      return null;
    },
  );
}

http.Client offlineSessionStartClient() {
  return buildBackendMockClient(
    override: (request) async {
      if (request.url.path == '/session/start') {
        throw http.ClientException('offline');
      }

      return null;
    },
  );
}
