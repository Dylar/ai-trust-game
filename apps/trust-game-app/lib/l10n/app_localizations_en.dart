// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Trust Game';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeDescription =>
      'Start a new session or continue one of the recent sessions.';

  @override
  String get homeStartSessionButton => 'Start new session';

  @override
  String get homeRecentSessionsTitle => 'Recent sessions';

  @override
  String get homeRecentSessionsDescription =>
      'These sessions are kept for the current app runtime.';

  @override
  String get homeEmptySessions => 'No sessions are available yet.';

  @override
  String get homeNoInteractionPreview => 'No interaction yet.';

  @override
  String get homeResumeSessionHint => 'Open session';

  @override
  String homeSessionSummary(String role, String mode) {
    return '$role in $mode mode';
  }

  @override
  String get sessionStartTitle => 'Session Start';

  @override
  String get sessionStartDescription =>
      'Pick the initial role and trust mode for the game.';

  @override
  String get roleSectionTitle => 'Role';

  @override
  String get modeSectionTitle => 'Mode';

  @override
  String get prepareSessionButton => 'Prepare session';

  @override
  String get preparingSessionButton => 'Preparing session...';

  @override
  String get sessionStartLoadingTitle => 'Preparing session';

  @override
  String get sessionStartLoadingDescription =>
      'The app is asking the backend to start a session.';

  @override
  String get sessionStartErrorTitle => 'Session start failed';

  @override
  String get sessionStartErrorDescription =>
      'The session could not be prepared. Please try again.';

  @override
  String get apiErrorInvalidJson =>
      'The request could not be read by the backend.';

  @override
  String get apiErrorMethodNotAllowed =>
      'This action is not supported by the backend endpoint.';

  @override
  String get apiErrorInternal => 'The backend ran into an internal error.';

  @override
  String get apiErrorInvalidRole => 'The selected role is not supported.';

  @override
  String get apiErrorInvalidMode => 'The selected mode is not supported.';

  @override
  String get apiErrorMissingSession => 'The request did not include a session.';

  @override
  String get apiErrorSessionNotFound =>
      'The session could not be found on the backend.';

  @override
  String get apiErrorEmptyMessage => 'The message cannot be empty.';

  @override
  String get apiErrorMissingAnalysisRequest =>
      'No request was selected for analysis.';

  @override
  String get apiErrorRequestAnalysisNotFound =>
      'No analysis is available for this interaction yet.';

  @override
  String get apiErrorMissingAnalysisSession =>
      'No session was selected for analysis.';

  @override
  String get apiErrorSessionAnalysisNotFound =>
      'No analysis is available for this session yet.';

  @override
  String get apiErrorBackendUnreachable =>
      'The backend is not reachable. Please check whether the service is running.';

  @override
  String get apiErrorRequestTimeout =>
      'The backend did not respond in time. Please try again.';

  @override
  String get apiErrorUnknown => 'The backend returned an unexpected error.';

  @override
  String get sessionRoleGuest => 'Guest';

  @override
  String get sessionRoleEmployee => 'Employee';

  @override
  String get sessionRoleAdmin => 'Admin';

  @override
  String get sessionModeEasy => 'Easy';

  @override
  String get sessionModeEasyDescription =>
      'Permissive and intentionally insecure.';

  @override
  String get sessionModeMedium => 'Medium';

  @override
  String get sessionModeMediumDescription =>
      'Partial checks with still-mixed trust boundaries.';

  @override
  String get sessionModeHard => 'Hard';

  @override
  String get sessionModeHardDescription =>
      'Server-side state stays authoritative.';

  @override
  String sessionPreparedStatus(String role, String mode) {
    return 'Started $role session in $mode mode.';
  }

  @override
  String get interactionTitle => 'Interaction';

  @override
  String get interactionDescription =>
      'Send messages for this session. Analysis stays in the detail views so the next attempt is still yours.';

  @override
  String get interactionSessionDetailsTitle => 'Session details';

  @override
  String get interactionSessionIdLabel => 'Session ID';

  @override
  String get interactionRoleLabel => 'Role';

  @override
  String get interactionModeLabel => 'Mode';

  @override
  String get sessionAnalysisButton => 'View session analysis';

  @override
  String get interactionMessageInputLabel => 'Message';

  @override
  String get interactionMessageInputHint => 'Ask something for this session...';

  @override
  String get interactionSendButton => 'Send message';

  @override
  String get interactionSendButtonLoading => 'Sending...';

  @override
  String get interactionSendErrorTitle => 'Message could not be sent';

  @override
  String get interactionSendErrorDescription =>
      'The backend did not accept the message. Please try again.';

  @override
  String get interactionListTitle => 'Interactions';

  @override
  String get interactionListEmpty => 'No interactions have been created yet.';

  @override
  String get interactionAnalysisHint => 'View interaction analysis';

  @override
  String get interactionUserMessageLabel => 'You';

  @override
  String get interactionAssistantMessageLabel => 'Assistant';

  @override
  String get interactionLoadErrorDescription =>
      'The session could not be loaded. Please go back and try again.';

  @override
  String interactionNotFoundDescription(String sessionId) {
    return 'No local session with ID $sessionId is available.';
  }

  @override
  String get sessionDetailTitle => 'Session Analysis';

  @override
  String get sessionDetailAnalysisEmpty =>
      'No interactions are available yet for a session analysis.';

  @override
  String get sessionDetailRequestsTitle => 'Requests in this session';

  @override
  String get sessionDetailRequestsDescription =>
      'Open a request to inspect its detailed analysis.';

  @override
  String get sessionDetailRequestsEmpty =>
      'No request analyses are available yet.';

  @override
  String sessionDetailRequestSummary(
    String classification,
    int suspicionCount,
    int modelFailCount,
  ) {
    return '$classification · Suspicion signals: $suspicionCount · Model failures: $modelFailCount';
  }

  @override
  String get interactionDetailTitle => 'Interaction Analysis';

  @override
  String get analysisLoadErrorDescription =>
      'The analysis could not be loaded yet.';

  @override
  String analysisHttpError(int statusCode) {
    return 'HTTP status: $statusCode';
  }

  @override
  String get analysisSessionIdLabel => 'Session ID';

  @override
  String get analysisRequestIdLabel => 'Request ID';

  @override
  String get analysisClassificationLabel => 'Classification';

  @override
  String get analysisRequestCountLabel => 'Requests';

  @override
  String get analysisEventCountLabel => 'Events';

  @override
  String get analysisSuspicionCountLabel => 'Suspicion signals';

  @override
  String get analysisModelFailCountLabel => 'Model failures';

  @override
  String get analysisSignalsLabel => 'Signals';

  @override
  String get analysisAttackPatternsLabel => 'Attack patterns';

  @override
  String get analysisIntentSummaryLabel => 'Intent summary';

  @override
  String get analysisEmptyListValue => 'None';
}
