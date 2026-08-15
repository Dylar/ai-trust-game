import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../testing/mocks/analysis_api_mocks.dart';

MockClient missingRequestAnalysisClient() {
  return MockClient(
    (_) async => http.Response(
      jsonEncode(<String, Object>{
        'error': <String, String>{'code': 'request_analysis_not_found'},
      }),
      HttpStatus.notFound,
    ),
  );
}

typedef PendingRefreshRequestAnalysisApi = PendingRequestAnalysisApi;
