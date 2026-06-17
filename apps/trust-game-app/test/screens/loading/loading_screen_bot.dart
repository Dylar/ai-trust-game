import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/loading/loading_keys.dart';
import 'package:app/screens/login/login_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class LoadingScreenBot extends BaseScreenBot {
  LoadingScreenBot(super.tester);

  void expectLoadingVisible() {
    expect(isVisible(LoadingKeys.loadingIndicator), isTrue);
  }

  void expectLoadingStepsVisible() {
    final context = tester.element(getFinder(LoadingKeys.screen));
    final l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.loadingUserProfilesStep), findsOneWidget);
    expect(find.text(l10n.loadingSyncSavedUsersStep), findsOneWidget);
  }

  void expectRetryVisible() {
    expect(isVisible(LoadingKeys.retryButton), isTrue);
  }

  void expectLoginVisible() {
    expect(isVisible(LoginKeys.screen), isTrue);
  }
}
