import 'dart:convert';
import 'dart:io';

import 'package:app/core/user/user_profile.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:app/data/auth/auth_dto.dart';
import 'package:http/http.dart' as http;

class AuthApiClient {
  const AuthApiClient({required this.httpClient, required this.apiBaseUri});

  final http.Client httpClient;
  final Uri apiBaseUri;

  Future<List<UserProfile>> listUsers() async {
    try {
      final json = await sendGetJsonRequest(
        httpClient,
        apiBaseUri.resolve('/auth/users'),
      );
      final response = ListAuthUsersResponse.fromJson(json);
      return response.users.map((user) => user.toUserProfile()).toList();
    } on ApiException catch (error) {
      throw AuthApiException.fromApiException(error);
    }
  }

  Future<UserProfile> createUser(String displayName) async {
    try {
      final response = await sendPostRequest(
        httpClient,
        apiBaseUri.resolve('/auth/users'),
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: CreateAuthUserRequest(displayName: displayName).toJson(),
      );
      ensureSuccessResponse(
        response,
        successStatusCodes: const <int>{HttpStatus.created},
      );
      return AuthUserResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      ).toUserProfile();
    } on ApiException catch (error) {
      throw AuthApiException.fromApiException(error);
    }
  }
}

class AuthApiException extends ApiException {
  const AuthApiException({required super.statusCode, super.error});

  factory AuthApiException.fromApiException(ApiException error) {
    return AuthApiException(statusCode: error.statusCode, error: error.error);
  }
}
