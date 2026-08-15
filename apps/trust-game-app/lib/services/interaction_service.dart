import 'package:app/data/interaction/interaction_dto.dart';

import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/models/interaction_models.dart';

class InteractionService {
  const InteractionService({
    required this.apiClient,
    required this.interactionRepository,
  });

  final InteractionApi apiClient;
  final InteractionRepository interactionRepository;

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
