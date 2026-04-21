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
      'Starte eine neue Sitzung oder fahre mit einer der letzten Platzhalter-Sitzungen fort, während der Client-Flow Gestalt annimmt.';

  @override
  String get homeStartSessionButton => 'Neue Sitzung starten';

  @override
  String get homeRecentSessionsTitle => 'Letzte Sitzungen';

  @override
  String get homeRecentSessionsDescription =>
      'Das sind lokale Platzhalter-Sitzungen für die nächsten Routing- und Interaction-Schritte.';

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
      'Wähle die anfängliche Rolle und den Vertrauensmodus für das Spiel. Das ist der erste echte Frontend-Flow vor der Backend-Anbindung.';

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
      'Die App bereitet eine lokale Platzhalter-Sitzung vor, solange der Backend-Flow noch nicht angebunden ist.';

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
    return '$role-Sitzung im Modus $mode vorbereitet. Als Nächstes kommt der Backend-Start.';
  }

  @override
  String get interactionTitle => 'Interaction';

  @override
  String get interactionDescription =>
      'Das ist die erste Platzhalter-Ansicht fuer die Interaction. Aktuell zeigt sie die ausgewaehlten Sitzungsdaten, bevor der echte Nachrichtenaustausch angebunden ist.';

  @override
  String get interactionSessionDetailsTitle => 'Sitzungsdetails';

  @override
  String get interactionSessionIdLabel => 'Sitzungs-ID';

  @override
  String get interactionRoleLabel => 'Rolle';

  @override
  String get interactionModeLabel => 'Modus';

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
  String get interactionListTitle => 'Interactions';

  @override
  String get interactionListEmpty =>
      'Es wurden noch keine Interactions erstellt.';

  @override
  String get interactionLoadErrorDescription =>
      'Die Sitzung konnte nicht geladen werden. Bitte gehe zurueck und versuche es erneut.';

  @override
  String interactionNotFoundDescription(String sessionId) {
    return 'Keine lokale Sitzung mit der ID $sessionId gefunden.';
  }
}
