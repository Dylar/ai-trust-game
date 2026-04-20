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
}
