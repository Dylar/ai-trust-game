import '../../l10n/app_localizations.dart';
import 'session_start_screen_state.dart';

extension SessionRoleLocalization on SessionRole {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SessionRole.guest:
        return l10n.sessionRoleGuest;
      case SessionRole.employee:
        return l10n.sessionRoleEmployee;
      case SessionRole.admin:
        return l10n.sessionRoleAdmin;
    }
  }
}

extension SessionModeLocalization on SessionMode {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SessionMode.easy:
        return l10n.sessionModeEasy;
      case SessionMode.medium:
        return l10n.sessionModeMedium;
      case SessionMode.hard:
        return l10n.sessionModeHard;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case SessionMode.easy:
        return l10n.sessionModeEasyDescription;
      case SessionMode.medium:
        return l10n.sessionModeMediumDescription;
      case SessionMode.hard:
        return l10n.sessionModeHardDescription;
    }
  }
}
