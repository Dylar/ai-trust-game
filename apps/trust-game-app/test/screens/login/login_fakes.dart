import 'package:app/core/user/user_profile.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/auth/auth_api_client.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_dto.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/start_session_dto.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter/foundation.dart';

import '../../testing/test_user_profile.dart';

class FakeLoginAuthApi implements AuthApi {
  FakeLoginAuthApi({this.shouldFailCreate = false});

  final bool shouldFailCreate;
  String? createdDisplayName;

  @override
  Future<List<UserProfile>> listUsers() async => const <UserProfile>[];

  @override
  Future<UserProfile> createUser(String displayName) async {
    if (shouldFailCreate) {
      throw Exception('create failed');
    }
    createdDisplayName = displayName;
    final user = UserProfile(
      id: 'created-user',
      displayName: displayName,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    return user;
  }
}

class FakeLoginUserRepository implements UserRepository {
  const FakeLoginUserRepository({
    this.loadedUsers = const <UserProfile>[],
    this.unloadedUsers = const <UserProfile>[],
  });

  final List<UserProfile> loadedUsers;
  final List<UserProfile> unloadedUsers;

  @override
  Future<List<UserProfile>> listLoadedUsers() async => loadedUsers;

  @override
  Future<List<UserProfile>> listUnloadedUsers() async => unloadedUsers;

  @override
  Future<List<UserProfile>> listUsers() async {
    return <UserProfile>[...loadedUsers, ...unloadedUsers];
  }

  @override
  Future<void> saveUser(UserProfile user) async {}
}

class FakeLoginSessionApi implements SessionApi {
  FakeLoginSessionApi({
    this.sessions = const <Session>[],
    this.shouldFailListSessions = false,
  });

  final List<Session> sessions;
  final bool shouldFailListSessions;
  String? listedUserId;

  @override
  Future<ListSessionsResponse> listSessionsForUser(String userId) async {
    listedUserId = userId;
    if (shouldFailListSessions) {
      throw const ApiException(
        error: ApiError(code: ApiErrorCode.backendUnreachable),
      );
    }
    return ListSessionsResponse(sessions: sessions);
  }

  @override
  Future<StartSessionResponse> startSession(StartSessionRequest request) async {
    throw UnimplementedError();
  }
}

class FakeLoginInteractionApi implements InteractionApi {
  const FakeLoginInteractionApi();

  @override
  Future<InteractionResponse> createInteraction(
    InteractionRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ListInteractionsResponse> listInteractionsForSession({
    required String userId,
    required String sessionId,
  }) async {
    return const ListInteractionsResponse(
      interactions: <InteractionResponse>[],
    );
  }
}

class ThrowingSaveLoginSessionRepository implements SessionRepository {
  ThrowingSaveLoginSessionRepository();

  final ValueNotifier<List<Session>> _sessions = ValueNotifier<List<Session>>(
    const <Session>[],
  );

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async => null;

  @override
  Future<List<Session>> listSessions() async => const <Session>[];

  @override
  Future<void> saveSession(Session session) async {
    throw Exception('sync failed');
  }

  @override
  Future<void> saveSessionForUser({
    required String userId,
    required Session session,
  }) async {
    throw Exception('sync failed');
  }
}

UserProfile loadedLoginUserProfile(String id) {
  return UserProfile(
    id: id,
    displayName: id,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    lastActivityAt: DateTime.utc(2026),
  );
}

UserProfile unloadedLoginUserProfile(String id) {
  return testUserProfile(id);
}
