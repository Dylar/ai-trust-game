import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../testing/mocks/analysis_api_mocks.dart';

MockClient missingSessionAnalysisClient() {
  return MockClient(
    (_) async => http.Response(
      jsonEncode(<String, Object>{
        'error': <String, String>{'code': 'session_analysis_not_found'},
      }),
      HttpStatus.notFound,
    ),
  );
}

typedef PendingRefreshSessionAnalysisApi = PendingSessionAnalysisApi;
