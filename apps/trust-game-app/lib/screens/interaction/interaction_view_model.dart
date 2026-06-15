import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/screens/interaction/interaction_logger.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/services/interaction_service.dart';
import 'package:flutter/foundation.dart';

class InteractionViewModel {
  InteractionViewModel({
    required AppLogger appLogger,
    required InteractionRepository interactionRepository,
    required InteractionService interactionService,
    required SessionRepository sessionRepository,
    required String sessionId,
  }) : _logger = InteractionLogger(appLogger: appLogger),
       _interactionRepository = interactionRepository,
       _interactionService = interactionService,
       _sessionRepository = sessionRepository,
       stateNotifier = ValueNotifier(
         InteractionScreenState.initial(sessionId: sessionId),
       ) {
    _loadSessionData();
  }

  final InteractionLogger _logger;
  final InteractionRepository _interactionRepository;
  final InteractionService _interactionService;
  final SessionRepository _sessionRepository;

  final ValueNotifier<InteractionScreenState> stateNotifier;

  InteractionScreenState get state => stateNotifier.value;

  void dispose() {
    stateNotifier.dispose();
  }

  Future<void> _loadSessionData() async {
    try {
      final session = await _sessionRepository.getSession(state.sessionId);

      if (session == null) {
        stateNotifier.value = state.copyWith(
          status: InteractionScreenStatus.notFound,
          resetSession: true,
        );
        return;
      }

      final interactions = await _interactionRepository.listInteractions(
        state.sessionId,
      );

      stateNotifier.value = state.copyWith(
        status: InteractionScreenStatus.ready,
        session: session,
        interactions: interactions,
      );
    } catch (error, stackTrace) {
      await _logger.logLoadFailed(
        sessionId: state.sessionId,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = state.copyWith(
        status: InteractionScreenStatus.error,
        resetSession: true,
      );
    }
  }

  Future<void> submitMessage(String message) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty ||
        state.status != InteractionScreenStatus.ready ||
        state.isSubmitting) {
      return;
    }

    stateNotifier.value = state.copyWith(isSubmitting: true, resetError: true);

    try {
      await _interactionService.createInteraction(
        sessionId: state.sessionId,
        message: normalizedMessage,
      );
      final interactions = await _interactionRepository.listInteractions(
        state.sessionId,
      );

      stateNotifier.value = state.copyWith(
        interactions: interactions,
        isSubmitting: false,
      );
    } on ApiException catch (error, stackTrace) {
      await _logger.logSubmissionFailed(
        sessionId: state.sessionId,
        message: normalizedMessage,
        error: error,
        stackTrace: stackTrace,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      stateNotifier.value = state.copyWith(
        error: const InteractionScreenError(),
        isSubmitting: false,
      );
    } catch (error, stackTrace) {
      await _logger.logSubmissionFailed(
        sessionId: state.sessionId,
        message: normalizedMessage,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = state.copyWith(
        error: const InteractionScreenError(),
        isSubmitting: false,
      );
    }
  }

  void clearError() {
    stateNotifier.value = state.copyWith(resetError: true);
  }
}
