import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Trust Game'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a new session or continue one of the recent sessions.'**
  String get homeDescription;

  /// No description provided for @homeStartSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Start new session'**
  String get homeStartSessionButton;

  /// No description provided for @homeRecentSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get homeRecentSessionsTitle;

  /// No description provided for @homeRecentSessionsDescription.
  ///
  /// In en, this message translates to:
  /// **'These sessions are kept for the current app runtime.'**
  String get homeRecentSessionsDescription;

  /// No description provided for @homeEmptySessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions are available yet.'**
  String get homeEmptySessions;

  /// No description provided for @homeResumeSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Open session'**
  String get homeResumeSessionHint;

  /// No description provided for @homeSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{role} in {mode} mode'**
  String homeSessionSummary(String role, String mode);

  /// No description provided for @sessionStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Start'**
  String get sessionStartTitle;

  /// No description provided for @sessionStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the initial role and trust mode for the game.'**
  String get sessionStartDescription;

  /// No description provided for @roleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleSectionTitle;

  /// No description provided for @modeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get modeSectionTitle;

  /// No description provided for @prepareSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Prepare session'**
  String get prepareSessionButton;

  /// No description provided for @preparingSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Preparing session...'**
  String get preparingSessionButton;

  /// No description provided for @sessionStartLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing session'**
  String get sessionStartLoadingTitle;

  /// No description provided for @sessionStartLoadingDescription.
  ///
  /// In en, this message translates to:
  /// **'The app is asking the backend to start a session.'**
  String get sessionStartLoadingDescription;

  /// No description provided for @sessionStartErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Session start failed'**
  String get sessionStartErrorTitle;

  /// No description provided for @sessionStartErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'The session could not be prepared. Please try again.'**
  String get sessionStartErrorDescription;

  /// No description provided for @sessionRoleGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get sessionRoleGuest;

  /// No description provided for @sessionRoleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get sessionRoleEmployee;

  /// No description provided for @sessionRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get sessionRoleAdmin;

  /// No description provided for @sessionModeEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get sessionModeEasy;

  /// No description provided for @sessionModeEasyDescription.
  ///
  /// In en, this message translates to:
  /// **'Permissive and intentionally insecure.'**
  String get sessionModeEasyDescription;

  /// No description provided for @sessionModeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sessionModeMedium;

  /// No description provided for @sessionModeMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'Partial checks with still-mixed trust boundaries.'**
  String get sessionModeMediumDescription;

  /// No description provided for @sessionModeHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get sessionModeHard;

  /// No description provided for @sessionModeHardDescription.
  ///
  /// In en, this message translates to:
  /// **'Server-side state stays authoritative.'**
  String get sessionModeHardDescription;

  /// No description provided for @sessionPreparedStatus.
  ///
  /// In en, this message translates to:
  /// **'Started {role} session in {mode} mode.'**
  String sessionPreparedStatus(String role, String mode);

  /// No description provided for @interactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get interactionTitle;

  /// No description provided for @interactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Send messages for this session. Analysis stays in the detail views so the next attempt is still yours.'**
  String get interactionDescription;

  /// No description provided for @interactionSessionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session details'**
  String get interactionSessionDetailsTitle;

  /// No description provided for @interactionSessionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get interactionSessionIdLabel;

  /// No description provided for @interactionRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get interactionRoleLabel;

  /// No description provided for @interactionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get interactionModeLabel;

  /// No description provided for @sessionAnalysisButton.
  ///
  /// In en, this message translates to:
  /// **'View session analysis'**
  String get sessionAnalysisButton;

  /// No description provided for @interactionMessageInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get interactionMessageInputLabel;

  /// No description provided for @interactionMessageInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask something for this session...'**
  String get interactionMessageInputHint;

  /// No description provided for @interactionSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get interactionSendButton;

  /// No description provided for @interactionSendButtonLoading.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get interactionSendButtonLoading;

  /// No description provided for @interactionSendErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Message could not be sent'**
  String get interactionSendErrorTitle;

  /// No description provided for @interactionSendErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'The backend did not accept the message. Please try again.'**
  String get interactionSendErrorDescription;

  /// No description provided for @interactionListTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get interactionListTitle;

  /// No description provided for @interactionListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No interactions have been created yet.'**
  String get interactionListEmpty;

  /// No description provided for @interactionAnalysisHint.
  ///
  /// In en, this message translates to:
  /// **'View interaction analysis'**
  String get interactionAnalysisHint;

  /// No description provided for @interactionUserMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get interactionUserMessageLabel;

  /// No description provided for @interactionAssistantMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get interactionAssistantMessageLabel;

  /// No description provided for @interactionLoadErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'The session could not be loaded. Please go back and try again.'**
  String get interactionLoadErrorDescription;

  /// No description provided for @interactionNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'No local session with ID {sessionId} is available.'**
  String interactionNotFoundDescription(String sessionId);

  /// No description provided for @sessionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Analysis'**
  String get sessionDetailTitle;

  /// No description provided for @interactionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction Analysis'**
  String get interactionDetailTitle;

  /// No description provided for @analysisLoadErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'The analysis could not be loaded yet.'**
  String get analysisLoadErrorDescription;

  /// No description provided for @analysisHttpError.
  ///
  /// In en, this message translates to:
  /// **'HTTP status: {statusCode}'**
  String analysisHttpError(int statusCode);

  /// No description provided for @analysisSessionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get analysisSessionIdLabel;

  /// No description provided for @analysisRequestIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get analysisRequestIdLabel;

  /// No description provided for @analysisClassificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get analysisClassificationLabel;

  /// No description provided for @analysisRequestCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get analysisRequestCountLabel;

  /// No description provided for @analysisEventCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get analysisEventCountLabel;

  /// No description provided for @analysisSuspicionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspicion signals'**
  String get analysisSuspicionCountLabel;

  /// No description provided for @analysisModelFailCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Model failures'**
  String get analysisModelFailCountLabel;

  /// No description provided for @analysisSignalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get analysisSignalsLabel;

  /// No description provided for @analysisAttackPatternsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attack patterns'**
  String get analysisAttackPatternsLabel;

  /// No description provided for @analysisIntentSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Intent summary'**
  String get analysisIntentSummaryLabel;

  /// No description provided for @analysisEmptyListValue.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get analysisEmptyListValue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
