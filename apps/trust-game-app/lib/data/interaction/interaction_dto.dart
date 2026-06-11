class InteractionRequest {
  const InteractionRequest({required this.sessionId, required this.message});

  final String sessionId;
  final String message;

  Map<String, String> toJson() {
    return <String, String>{'message': message};
  }
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

  factory InteractionResponse.fromBackend({
    required String sessionId,
    required String requestId,
    required String requestMessage,
    required Map<String, dynamic> json,
  }) {
    return InteractionResponse(
      sessionId: sessionId,
      interactionId: requestId,
      message: requestMessage,
      answer: json['message'] as String,
    );
  }
}

class ListInteractionsResponse {
  const ListInteractionsResponse({required this.interactions});

  final List<InteractionResponse> interactions;

  factory ListInteractionsResponse.fromJson(Map<String, dynamic> json) {
    final interactionsJson =
        json['interactions'] as List<dynamic>? ?? <dynamic>[];
    return ListInteractionsResponse(
      interactions: interactionsJson
          .map((item) => _interactionFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

InteractionResponse _interactionFromJson(Map<String, dynamic> json) {
  return InteractionResponse(
    sessionId: json['sessionId'] as String,
    interactionId: json['requestId'] as String,
    message: json['message'] as String,
    answer: json['answer'] as String,
  );
}
