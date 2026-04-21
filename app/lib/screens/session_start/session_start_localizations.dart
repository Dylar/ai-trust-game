import '../../l10n/app_localizations.dart';
import '../../models/session_models.dart';

extension RoleLocalization on Role {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case Role.guest:
        return l10n.sessionRoleGuest;
      case Role.employee:
        return l10n.sessionRoleEmployee;
      case Role.admin:
        return l10n.sessionRoleAdmin;
    }
  }
}

extension ModeLocalization on Mode {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case Mode.easy:
        return l10n.sessionModeEasy;
      case Mode.medium:
        return l10n.sessionModeMedium;
      case Mode.hard:
        return l10n.sessionModeHard;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case Mode.easy:
        return l10n.sessionModeEasyDescription;
      case Mode.medium:
        return l10n.sessionModeMediumDescription;
      case Mode.hard:
        return l10n.sessionModeHardDescription;
    }
  }
}
