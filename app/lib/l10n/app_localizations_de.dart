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
}
