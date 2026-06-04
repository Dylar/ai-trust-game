import 'dart:async';
import 'dart:convert';

import 'package:app/data/api/api_error.dart';
import 'package:http/http.dart' as http;

const apiRequestTimeout = Duration(seconds: 10);

Map<String, String> buildHeaders({
  required String userId,
  String? sessionId,
  bool includeJsonContentType = false,
}) {
  final headers = <String, String>{'X-User-Id': userId};

  if (includeJsonContentType) {
    headers['Content-Type'] = 'application/json';
  }
  if (sessionId != null) {
    headers['X-Session-Id'] = sessionId;
  }

  return headers;
}

Future<http.Response> sendGetRequest(
  http.Client client,
  Uri url, {
  Map<String, String>? headers,
  Duration timeout = apiRequestTimeout,
}) async {
  return _sendApiRequest(
    () => client.get(url, headers: headers),
    timeout: timeout,
  );
}

Future<http.Response> sendPostRequest(
  http.Client client,
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = apiRequestTimeout,
}) async {
  return _sendApiRequest(
    () => client.post(url, headers: headers, body: jsonEncode(body)),
    timeout: timeout,
  );
}

Future<Map<String, dynamic>> sendGetJsonRequest(
  http.Client client,
  Uri url, {
  Map<String, String>? headers,
  Duration timeout = apiRequestTimeout,
}) async {
  final response = await sendGetRequest(
    client,
    url,
    headers: headers,
    timeout: timeout,
  );

  return parseJsonResponse(response);
}

Future<Map<String, dynamic>> sendPostJsonRequest(
  http.Client client,
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = apiRequestTimeout,
}) async {
  final response = await sendPostRequest(
    client,
    url,
    headers: headers,
    body: body,
    timeout: timeout,
  );

  return parseJsonResponse(response);
}

Future<http.Response> _sendApiRequest(
  Future<http.Response> Function() send, {
  Duration timeout = apiRequestTimeout,
}) async {
  try {
    return await send().timeout(timeout);
  } on TimeoutException {
    throw const ApiException(
      error: ApiError(code: ApiErrorCode.requestTimeout),
    );
  } on http.ClientException {
    throw const ApiException(
      error: ApiError(code: ApiErrorCode.backendUnreachable),
    );
  }
}

Map<String, dynamic> parseJsonResponse(http.Response response) {
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  throw buildApiException(response);
}

void ensureSuccessResponse(
  http.Response response, {
  Set<int>? successStatusCodes,
}) {
  final isSuccessfulStatus =
      successStatusCodes?.contains(response.statusCode) ??
      (response.statusCode >= 200 && response.statusCode < 300);

  if (isSuccessfulStatus) {
    return;
  }

  throw buildApiException(response);
}

ApiException buildApiException(http.Response response) {
  return ApiException(
    statusCode: response.statusCode,
    error: _parseError(response.body),
  );
}

ApiError? _parseError(String body) {
  try {
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final error = json['error'];
    if (error is! Map<String, dynamic>) {
      return null;
    }

    final value = error['code'];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    final code = ApiErrorCode.fromCode(value);
    if (code == null) {
      return null;
    }

    return ApiError(code: code);
  } catch (_) {
    return null;
  }
}
