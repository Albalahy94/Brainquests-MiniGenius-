// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mini Genius';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get play => 'Play';

  @override
  String get worlds => 'Worlds';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get parentDashboard => 'Parent Dashboard';

  @override
  String get shop => 'Shop';

  @override
  String get achievements => 'Achievements';

  @override
  String get timeLimitReached => 'Time limit reached! Go to Parent Dashboard?';

  @override
  String get gameRestricted => 'This game is restricted by parents.';

  @override
  String get appearance => 'Appearance';

  @override
  String get legal => 'Legal';

  @override
  String get about => 'About';

  @override
  String get deleteAccount => 'Delete Account Data';

  @override
  String get deleteAccountConfirmTitle => 'Delete All Data?';

  @override
  String get deleteAccountConfirmMessage =>
      'This will permanently delete all your progress, achievements, and purchased items. This action cannot be undone.';

  @override
  String get deleteAccountConfirmButton => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String streakDays(int count) {
    return '$count days streak';
  }

  @override
  String challengeGoal(int score) {
    return 'Goal: $score points';
  }

  @override
  String get challengeCompleted => 'Challenge Completed!';

  @override
  String get rewards => 'Rewards';

  @override
  String rewardStars(int stars) {
    return '$stars Stars';
  }

  @override
  String rewardCoins(int coins) {
    return '$coins Coins';
  }

  @override
  String get startGame => 'Start Game';

  @override
  String get enterPassword => 'Please enter the password';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get setPassword => 'Set Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterStrongPassword => 'Enter a strong password';

  @override
  String get reenterPassword => 'Re-enter password';

  @override
  String get save => 'Save';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 4 characters';

  @override
  String get passwordSetSuccess => 'Password set successfully';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match';

  @override
  String get passwordChangeSuccess => 'Password changed successfully';

  @override
  String get playTimeToday => 'Play Time Today';

  @override
  String get minutes => 'minutes';

  @override
  String get minutesUnit => 'min';

  @override
  String maxPlayTimeLimit(int limit) {
    return 'Limit: $limit minutes';
  }

  @override
  String get noLimit => 'No Limit';

  @override
  String get notSet => 'Not Set';

  @override
  String get games => 'Games';

  @override
  String get levels => 'Levels';

  @override
  String get stars => 'Stars';

  @override
  String get playTime => 'Play Time';

  @override
  String get charts => 'Charts';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get playCountPerGame => 'Play Count Per Game';

  @override
  String get gameDistribution => 'Game Distribution';

  @override
  String get noStatsYet => 'No statistics yet';

  @override
  String get gameStatistics => 'Game Statistics';

  @override
  String get timesUnit => 'times';

  @override
  String averageScore(String score) {
    return 'Average: $score';
  }

  @override
  String get enableParentMode => 'Enable Parent Mode';

  @override
  String get dailyPlayTimeLimit => 'Daily Play Time Limit';

  @override
  String get allowedGames => 'Allowed Games';

  @override
  String get allGamesAllowed => 'All Games';

  @override
  String get ageGroup => 'Age Group';

  @override
  String get yearsUnit => 'years';

  @override
  String get achievementAlerts => 'Achievement Alerts';

  @override
  String get notifyNewAchievement =>
      'Notify when a new achievement is unlocked';

  @override
  String get passwordIsSet => 'Password is set';

  @override
  String get passwordNotSet => 'Password is not set';

  @override
  String get passwordNotSetYet => 'Password is not set yet';

  @override
  String get enter => 'Enter';

  @override
  String get allGamesEnabledSuccess => 'All games enabled';

  @override
  String get allowedGamesUpdatedSuccess => 'Allowed games updated';

  @override
  String get childAgeGroupTitle => 'Child\'s Age Group';

  @override
  String yearsRange(int min, int max) {
    return '$min-$max years';
  }

  @override
  String ageRangeAbove(int age) {
    return '$age+ years';
  }

  @override
  String get gameNameMemoryCards => 'Memory Cards';

  @override
  String get gameNameFindDifference => 'Find the Difference';

  @override
  String get gameNameShapeMatcher => 'Shape Matcher';

  @override
  String get gameNamePatternLogic => 'Pattern Logic';

  @override
  String get gameNameQuickMath => 'Quick Math';

  @override
  String get gameNameColorMemory => 'Color Memory';

  @override
  String get gameNameWordPuzzle => 'Word Puzzle';

  @override
  String get gameNameMazeRunner => 'Maze Runner';

  @override
  String get gameNameSortingGame => 'Sorting Game';

  @override
  String get gameNameJigsawPuzzle => 'Jigsaw Puzzle';

  @override
  String get childProgressReportTitle => 'Child Progress Report - MiniGenius';

  @override
  String get reportDate => 'Report Date';

  @override
  String get pdfTableGame => 'Game';

  @override
  String get pdfTableTimes => 'Times Played';

  @override
  String get pdfTableAvgScore => 'Average Score';

  @override
  String get star => 'Star';

  @override
  String worldLockedMessage(int stars) {
    return 'This world is locked. You need $stars stars to unlock it.';
  }

  @override
  String levelsCount(int count) {
    return '$count Levels';
  }

  @override
  String chooseGameForLevel(int level) {
    return 'Choose Game - Level $level';
  }

  @override
  String get worldLockedPrompt =>
      'This world is locked. Please unlock it first.';

  @override
  String get contactDeveloper => 'Contact Developer';

  @override
  String get parentalGateTitle => 'Parent Verification';

  @override
  String get parentalGateDescription =>
      'This section is for parents only. Please answer the question to continue.';

  @override
  String get parentalGateWrongAnswer => 'Incorrect answer. Please try again.';

  @override
  String get parentalGateContinue => 'Continue';
}
