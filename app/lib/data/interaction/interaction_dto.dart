class InteractionRequest {
  const InteractionRequest({required this.sessionId, required this.message});

  final String sessionId;
  final String message;
}

class InteractionResponse {
  const InteractionResponse({
    required this.sessionId,
    required this.interactionId,
    required this.message,
    required this.answer,
  });

  final String sessionId;
  final String interactionId;
  final String message;
  final String answer;
}
