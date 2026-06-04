class Interaction {
  const Interaction({
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
