import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/services/interaction_service.dart';

class SuccessfulInteractionService implements InteractionService {
  const SuccessfulInteractionService({
    required this.interactionRepository,
    this.interactionId = 'interaction-1',
    this.answer = 'Hi back',
  });

  final String answer;
  final String interactionId;
  final InteractionRepository interactionRepository;

  @override
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  }) async {
    final interaction = Interaction(
      sessionId: sessionId,
      interactionId: interactionId,
      message: message,
      answer: answer,
    );
    await interactionRepository.saveInteraction(interaction);
    return interaction;
  }
}

class ApiFailingInteractionService implements InteractionService {
  const ApiFailingInteractionService({
    required this.statusCode,
    required this.code,
  });

  final int statusCode;
  final ApiErrorCode code;

  @override
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  }) {
    throw ApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }
}
