import 'package:app/data/interaction/interaction_dto.dart';

import '../data/interaction/interaction_api_client.dart';
import '../data/interaction/interaction_repository.dart';
import '../models/interaction_models.dart';

abstract interface class InteractionService {
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  });
}

class InteractionServiceImpl implements InteractionService {
  const InteractionServiceImpl({
    required this.apiClient,
    required this.interactionRepository,
  });

  final InteractionApiClient apiClient;
  final InteractionRepository interactionRepository;

  @override
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  }) async {
    final result = await apiClient.createInteraction(
      InteractionRequest(sessionId: sessionId, message: message),
    );

    final interaction = Interaction(
      sessionId: result.sessionId,
      interactionId: result.interactionId,
      message: result.message,
      answer: result.answer,
    );

    await interactionRepository.saveInteraction(interaction);

    return interaction;
  }
}
