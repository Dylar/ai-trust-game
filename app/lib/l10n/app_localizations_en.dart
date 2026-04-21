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
      'Start a new session or continue one of the recent placeholder sessions while the client-side flow takes shape.';

  @override
  String get homeStartSessionButton => 'Start new session';

  @override
  String get homeRecentSessionsTitle => 'Recent sessions';

  @override
  String get homeRecentSessionsDescription =>
      'These are local placeholder sessions for the next routing and interaction steps.';

  @override
  String get homeEmptySessions => 'No sessions are available yet.';

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
      'Pick the initial role and trust mode for the game. This is the first real frontend flow before backend wiring.';

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
      'The app is preparing a local placeholder session while the backend flow is not connected yet.';

  @override
  String get sessionStartErrorTitle => 'Session start failed';

  @override
  String get sessionStartErrorDescription =>
      'The session could not be prepared. Please try again.';

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
    return 'Prepared $role session in $mode mode. Backend start comes next.';
  }

  @override
  String get interactionTitle => 'Interaction';

  @override
  String get interactionDescription =>
      'This is the first placeholder interaction view. It currently shows the selected session data before real message exchange is connected.';

  @override
  String get interactionSessionDetailsTitle => 'Session details';

  @override
  String get interactionSessionIdLabel => 'Session ID';

  @override
  String get interactionRoleLabel => 'Role';

  @override
  String get interactionModeLabel => 'Mode';

  @override
  String get interactionListTitle => 'Interactions';

  @override
  String get interactionListEmpty => 'No interactions have been created yet.';

  @override
  String get interactionLoadErrorDescription =>
      'The session could not be loaded. Please go back and try again.';

  @override
  String interactionNotFoundDescription(String sessionId) {
    return 'No local session with ID $sessionId is available.';
  }
}
