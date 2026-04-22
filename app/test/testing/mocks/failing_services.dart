import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';

class FailingInteractionService implements InteractionService {
  const FailingInteractionService();

  @override
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  }) {
    throw Exception('boom');
  }
}

class FailingSessionService implements SessionService {
  const FailingSessionService();

  @override
  Future<Session> startSession({required Role role, required Mode mode}) {
    throw Exception('boom');
  }
}
