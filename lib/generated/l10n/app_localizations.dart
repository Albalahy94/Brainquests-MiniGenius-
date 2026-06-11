import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Mini Genius'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @worlds.
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get worlds;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @parentDashboard.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get parentDashboard;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @timeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Time limit reached! Go to Parent Dashboard?'**
  String get timeLimitReached;

  /// No description provided for @gameRestricted.
  ///
  /// In en, this message translates to:
  /// **'This game is restricted by parents.'**
  String get gameRestricted;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Data'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your progress, achievements, and purchased items. This action cannot be undone.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteAccountConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountConfirmButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days streak'**
  String streakDays(int count);

  /// No description provided for @challengeGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {score} points'**
  String challengeGoal(int score);

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge Completed!'**
  String get challengeCompleted;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @rewardStars.
  ///
  /// In en, this message translates to:
  /// **'{stars} Stars'**
  String rewardStars(int stars);

  /// No description provided for @rewardCoins.
  ///
  /// In en, this message translates to:
  /// **'{coins} Coins'**
  String rewardCoins(int coins);

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the password'**
  String get enterPassword;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a strong password'**
  String get enterStrongPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reenterPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password set successfully'**
  String get passwordSetSuccess;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangeSuccess;

  /// No description provided for @playTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Play Time Today'**
  String get playTimeToday;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesUnit;

  /// No description provided for @maxPlayTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit: {limit} minutes'**
  String maxPlayTimeLimit(int limit);

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No Limit'**
  String get noLimit;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @playTime.
  ///
  /// In en, this message translates to:
  /// **'Play Time'**
  String get playTime;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @playCountPerGame.
  ///
  /// In en, this message translates to:
  /// **'Play Count Per Game'**
  String get playCountPerGame;

  /// No description provided for @gameDistribution.
  ///
  /// In en, this message translates to:
  /// **'Game Distribution'**
  String get gameDistribution;

  /// No description provided for @noStatsYet.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet'**
  String get noStatsYet;

  /// No description provided for @gameStatistics.
  ///
  /// In en, this message translates to:
  /// **'Game Statistics'**
  String get gameStatistics;

  /// No description provided for @timesUnit.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get timesUnit;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average: {score}'**
  String averageScore(String score);

  /// No description provided for @enableParentMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Parent Mode'**
  String get enableParentMode;

  /// No description provided for @dailyPlayTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Play Time Limit'**
  String get dailyPlayTimeLimit;

  /// No description provided for @allowedGames.
  ///
  /// In en, this message translates to:
  /// **'Allowed Games'**
  String get allowedGames;

  /// No description provided for @allGamesAllowed.
  ///
  /// In en, this message translates to:
  /// **'All Games'**
  String get allGamesAllowed;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get ageGroup;

  /// No description provided for @yearsUnit.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get yearsUnit;

  /// No description provided for @achievementAlerts.
  ///
  /// In en, this message translates to:
  /// **'Achievement Alerts'**
  String get achievementAlerts;

  /// No description provided for @notifyNewAchievement.
  ///
  /// In en, this message translates to:
  /// **'Notify when a new achievement is unlocked'**
  String get notifyNewAchievement;

  /// No description provided for @passwordIsSet.
  ///
  /// In en, this message translates to:
  /// **'Password is set'**
  String get passwordIsSet;

  /// No description provided for @passwordNotSet.
  ///
  /// In en, this message translates to:
  /// **'Password is not set'**
  String get passwordNotSet;

  /// No description provided for @passwordNotSetYet.
  ///
  /// In en, this message translates to:
  /// **'Password is not set yet'**
  String get passwordNotSetYet;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @allGamesEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'All games enabled'**
  String get allGamesEnabledSuccess;

  /// No description provided for @allowedGamesUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Allowed games updated'**
  String get allowedGamesUpdatedSuccess;

  /// No description provided for @childAgeGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Age Group'**
  String get childAgeGroupTitle;

  /// No description provided for @yearsRange.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} years'**
  String yearsRange(int min, int max);

  /// No description provided for @ageRangeAbove.
  ///
  /// In en, this message translates to:
  /// **'{age}+ years'**
  String ageRangeAbove(int age);

  /// No description provided for @gameNameMemoryCards.
  ///
  /// In en, this message translates to:
  /// **'Memory Cards'**
  String get gameNameMemoryCards;

  /// No description provided for @gameNameFindDifference.
  ///
  /// In en, this message translates to:
  /// **'Find the Difference'**
  String get gameNameFindDifference;

  /// No description provided for @gameNameShapeMatcher.
  ///
  /// In en, this message translates to:
  /// **'Shape Matcher'**
  String get gameNameShapeMatcher;

  /// No description provided for @gameNamePatternLogic.
  ///
  /// In en, this message translates to:
  /// **'Pattern Logic'**
  String get gameNamePatternLogic;

  /// No description provided for @gameNameQuickMath.
  ///
  /// In en, this message translates to:
  /// **'Quick Math'**
  String get gameNameQuickMath;

  /// No description provided for @gameNameColorMemory.
  ///
  /// In en, this message translates to:
  /// **'Color Memory'**
  String get gameNameColorMemory;

  /// No description provided for @gameNameWordPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Word Puzzle'**
  String get gameNameWordPuzzle;

  /// No description provided for @gameNameMazeRunner.
  ///
  /// In en, this message translates to:
  /// **'Maze Runner'**
  String get gameNameMazeRunner;

  /// No description provided for @gameNameSortingGame.
  ///
  /// In en, this message translates to:
  /// **'Sorting Game'**
  String get gameNameSortingGame;

  /// No description provided for @gameNameJigsawPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Jigsaw Puzzle'**
  String get gameNameJigsawPuzzle;

  /// No description provided for @childProgressReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Child Progress Report - MiniGenius'**
  String get childProgressReportTitle;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Report Date'**
  String get reportDate;

  /// No description provided for @pdfTableGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get pdfTableGame;

  /// No description provided for @pdfTableTimes.
  ///
  /// In en, this message translates to:
  /// **'Times Played'**
  String get pdfTableTimes;

  /// No description provided for @pdfTableAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get pdfTableAvgScore;

  /// No description provided for @star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get star;

  /// No description provided for @worldLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This world is locked. You need {stars} stars to unlock it.'**
  String worldLockedMessage(int stars);

  /// No description provided for @levelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Levels'**
  String levelsCount(int count);

  /// No description provided for @chooseGameForLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose Game - Level {level}'**
  String chooseGameForLevel(int level);

  /// No description provided for @worldLockedPrompt.
  ///
  /// In en, this message translates to:
  /// **'This world is locked. Please unlock it first.'**
  String get worldLockedPrompt;

  /// No description provided for @contactDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Contact Developer'**
  String get contactDeveloper;

  /// No description provided for @parentalGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Verification'**
  String get parentalGateTitle;

  /// No description provided for @parentalGateDescription.
  ///
  /// In en, this message translates to:
  /// **'This section is for parents only. Please answer the question to continue.'**
  String get parentalGateDescription;

  /// No description provided for @parentalGateWrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer. Please try again.'**
  String get parentalGateWrongAnswer;

  /// No description provided for @parentalGateContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get parentalGateContinue;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
