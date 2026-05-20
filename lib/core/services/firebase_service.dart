import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  void initialize() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crashlytics collection
      _crashlytics?.setCrashlyticsCollectionEnabled(true);
    } catch (e) {
      // Ignore if firebase not ready
    }
  }

  // Analytics Methods
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> logGameStart(String gameId, int level) async {
    await logEvent('game_start', parameters: {
      'game_id': gameId,
      'level': level,
    });
  }

  Future<void> logGameComplete(
      String gameId, int level, int stars, int points) async {
    await logEvent('game_complete', parameters: {
      'game_id': gameId,
      'level': level,
      'stars': stars,
      'points': points,
    });
  }

  Future<void> logLevelUnlock(String gameId, int level) async {
    await logEvent('level_unlock', parameters: {
      'game_id': gameId,
      'level': level,
    });
  }

  Future<void> logPremiumPurchase() async {
    await logEvent('premium_purchase');
  }

  Future<void> setAnalyticsUserId(String userId) async {
    try {
      await _analytics?.setUserId(id: userId);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      // Handle error silently
    }
  }

  // Crashlytics Methods
  void logError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    _crashlytics?.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: false,
    );
  }

  void logFatalError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    _crashlytics?.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: true,
    );
  }

  void setCustomKey(String key, dynamic value) {
    _crashlytics?.setCustomKey(key, value);
  }

  void setCrashlyticsUserId(String userId) {
    _crashlytics?.setUserIdentifier(userId);
  }

  // Convenience method to set user ID for both services
  Future<void> setUserId(String userId) async {
    await setAnalyticsUserId(userId);
    setCrashlyticsUserId(userId);
  }
}
