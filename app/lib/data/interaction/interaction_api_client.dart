import 'package:app/data/interaction/interaction_dto.dart';

class InteractionApiClient {
  const InteractionApiClient();

  Future<InteractionResponse> createInteraction(
    InteractionRequest request,
  ) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return InteractionResponse(
      sessionId: request.sessionId,
      interactionId: 'local-$timestamp',
      message: request.message,
      answer: 'Placeholder answer for: "${request.message}"',
    );
  }
}
