// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'AI Trust Game';

  @override
  String get homeTitle => 'Start';

  @override
  String get homeDescription =>
      'Starte eine neue Sitzung oder fahre mit einer der letzten Sitzungen fort.';

  @override
  String get homeStartSessionButton => 'Neue Sitzung starten';

  @override
  String get homeRecentSessionsTitle => 'Letzte Sitzungen';

  @override
  String get homeRecentSessionsDescription =>
      'Diese Sitzungen bleiben fuer die aktuelle App-Laufzeit erhalten.';

  @override
  String get homeEmptySessions => 'Es sind noch keine Sitzungen vorhanden.';

  @override
  String get homeResumeSessionHint => 'Sitzung öffnen';

  @override
  String homeSessionSummary(String role, String mode) {
    return '$role im Modus $mode';
  }

  @override
  String get sessionStartTitle => 'Sitzungsstart';

  @override
  String get sessionStartDescription =>
      'Waehle die anfaengliche Rolle und den Vertrauensmodus fuer das Spiel.';

  @override
  String get roleSectionTitle => 'Rolle';

  @override
  String get modeSectionTitle => 'Modus';

  @override
  String get prepareSessionButton => 'Sitzung vorbereiten';

  @override
  String get preparingSessionButton => 'Sitzung wird vorbereitet...';

  @override
  String get sessionStartLoadingTitle => 'Sitzung wird vorbereitet';

  @override
  String get sessionStartLoadingDescription =>
      'Die App fragt das Backend nach einer neuen Sitzung.';

  @override
  String get sessionStartErrorTitle => 'Sitzungsstart fehlgeschlagen';

  @override
  String get sessionStartErrorDescription =>
      'Die Sitzung konnte nicht vorbereitet werden. Bitte versuche es erneut.';

  @override
  String get sessionRoleGuest => 'Gast';

  @override
  String get sessionRoleEmployee => 'Mitarbeiter';

  @override
  String get sessionRoleAdmin => 'Admin';

  @override
  String get sessionModeEasy => 'Einfach';

  @override
  String get sessionModeEasyDescription =>
      'Freizügig und absichtlich unsicher.';

  @override
  String get sessionModeMedium => 'Mittel';

  @override
  String get sessionModeMediumDescription =>
      'Teilweise Prüfungen mit weiterhin gemischten Vertrauensgrenzen.';

  @override
  String get sessionModeHard => 'Hart';

  @override
  String get sessionModeHardDescription =>
      'Serverseitiger Zustand bleibt autoritativ.';

  @override
  String sessionPreparedStatus(String role, String mode) {
    return '$role-Sitzung im Modus $mode gestartet.';
  }

  @override
  String get interactionTitle => 'Interaction';

  @override
  String get interactionDescription =>
      'Sende Nachrichten fuer diese Sitzung. Die Analyse bleibt in Detailansichten, damit der naechste Versuch weiterhin dir gehoert.';

  @override
  String get interactionSessionDetailsTitle => 'Sitzungsdetails';

  @override
  String get interactionSessionIdLabel => 'Sitzungs-ID';

  @override
  String get interactionRoleLabel => 'Rolle';

  @override
  String get interactionModeLabel => 'Modus';

  @override
  String get sessionAnalysisButton => 'Sitzungsanalyse ansehen';

  @override
  String get interactionMessageInputLabel => 'Nachricht';

  @override
  String get interactionMessageInputHint =>
      'Stelle eine Frage fuer diese Sitzung...';

  @override
  String get interactionSendButton => 'Nachricht senden';

  @override
  String get interactionSendButtonLoading => 'Wird gesendet...';

  @override
  String get interactionSendErrorTitle =>
      'Nachricht konnte nicht gesendet werden';

  @override
  String get interactionSendErrorDescription =>
      'Das Backend hat die Nachricht nicht angenommen. Bitte versuche es erneut.';

  @override
  String get interactionListTitle => 'Interactions';

  @override
  String get interactionListEmpty =>
      'Es wurden noch keine Interactions erstellt.';

  @override
  String get interactionAnalysisHint => 'Interaction-Analyse ansehen';

  String get interactionUserMessageLabel => 'Du';

  @override
  String get interactionAssistantMessageLabel => 'Assistant';

  @override
  String get interactionLoadErrorDescription =>
      'Die Sitzung konnte nicht geladen werden. Bitte gehe zurueck und versuche es erneut.';

  @override
  String interactionNotFoundDescription(String sessionId) {
    return 'Keine lokale Sitzung mit der ID $sessionId gefunden.';
  }

  @override
  String get sessionDetailTitle => 'Sitzungsanalyse';

  @override
  String get interactionDetailTitle => 'Interaction-Analyse';

  @override
  String get analysisLoadErrorDescription =>
      'Die Analyse konnte noch nicht geladen werden.';

  @override
  String analysisHttpError(int statusCode) {
    return 'HTTP-Status: $statusCode';
  }

  String get analysisSessionIdLabel => 'Sitzungs-ID';

  @override
  String get analysisRequestIdLabel => 'Request-ID';

  @override
  String get analysisClassificationLabel => 'Klassifikation';

  @override
  String get analysisRequestCountLabel => 'Requests';

  @override
  String get analysisEventCountLabel => 'Events';

  @override
  String get analysisSuspicionCountLabel => 'Verdachtssignale';

  @override
  String get analysisModelFailCountLabel => 'Modellfehler';

  @override
  String get analysisSignalsLabel => 'Signale';

  @override
  String get analysisAttackPatternsLabel => 'Angriffsmuster';

  @override
  String get analysisIntentSummaryLabel => 'Intent-Zusammenfassung';

  @override
  String get analysisEmptyListValue => 'Keine';
}
