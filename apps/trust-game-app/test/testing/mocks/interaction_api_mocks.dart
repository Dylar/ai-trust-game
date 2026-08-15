import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_dto.dart';

class SuccessfulInteractionApi implements InteractionApi {
  const SuccessfulInteractionApi({
    this.interactionId = 'interaction-1',
    this.answer = 'Hi back',
  });

  final String answer;
  final String interactionId;

  @override
  Future<InteractionResponse> createInteraction(
    InteractionRequest request,
  ) async {
    return InteractionResponse(
      sessionId: request.sessionId,
      interactionId: interactionId,
      message: request.message,
      answer: answer,
    );
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

class ApiFailingInteractionApi implements InteractionApi {
  const ApiFailingInteractionApi({
    required this.statusCode,
    required this.code,
  });

  final int statusCode;
  final ApiErrorCode code;

  @override
  Future<InteractionResponse> createInteraction(InteractionRequest request) {
    throw InteractionApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
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
