import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';

class ScreenTimeService extends ChangeNotifier {
  static final ScreenTimeService _instance = ScreenTimeService._internal();
  factory ScreenTimeService() => _instance;
  ScreenTimeService._internal();

  static const String _keyChildrenList = 'screen_time_children_list_v1';
  static const String _keyActiveChildId = 'screen_time_active_child_id_v1';

  List<ChildProfile> _children = [];
  String? _activeChildId;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<ChildProfile> get children => List.unmodifiable(_children);

  ChildProfile get activeChild {
    if (_children.isEmpty) {
      final defaultChild = ChildProfile(
        id: 'child_default',
        name: 'بطلنا الصغير',
        avatar: 'boy',
        age: 6,
        isScreenTimeEnabled: false,
        dailyLimitMinutes: 30,
      );
      _children.add(defaultChild);
      _activeChildId = defaultChild.id;
      return defaultChild;
    }

    final found = _children.firstWhere(
      (c) => c.id == _activeChildId,
      orElse: () => _children.first,
    );
    found.checkAndResetDaily();
    return found;
  }

  bool get isLocked => activeChild.isLimitReached;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final childrenJson = prefs.getString(_keyChildrenList);
      _activeChildId = prefs.getString(_keyActiveChildId);

      if (childrenJson != null && childrenJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(childrenJson);
        _children = decoded
            .map((item) => ChildProfile.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (_children.isEmpty) {
        final initialChild = ChildProfile(
          id: 'child_1',
          name: 'بطلنا العبقري',
          avatar: 'boy',
          age: 6,
          isScreenTimeEnabled: false,
          dailyLimitMinutes: 30,
        );
        _children = [initialChild];
        _activeChildId = initialChild.id;
        await _persist();
      } else {
        if (_activeChildId == null ||
            !_children.any((c) => c.id == _activeChildId)) {
          _activeChildId = _children.first.id;
        }
      }

      for (var child in _children) {
        child.checkAndResetDaily();
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('ScreenTimeService init error: $e');
      _isInitialized = true;
    }
  }

  Future<void> setActiveChild(String childId) async {
    if (_activeChildId == childId) return;
    final exists = _children.any((c) => c.id == childId);
    if (!exists) return;

    _activeChildId = childId;
    activeChild.checkAndResetDaily();
    await _persist();
    notifyListeners();
  }

  Future<void> saveChild(ChildProfile child) async {
    final index = _children.indexWhere((c) => c.id == child.id);
    if (index >= 0) {
      _children[index] = child;
    } else {
      _children.add(child);
      if (_children.length == 1) {
        _activeChildId = child.id;
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteChild(String childId) async {
    if (_children.length <= 1) {
      // Cannot delete the only profile, just reset its values
      return;
    }

    _children.removeWhere((c) => c.id == childId);
    if (_activeChildId == childId) {
      _activeChildId = _children.first.id;
    }
    await _persist();
    notifyListeners();
  }

  void recordTick({int seconds = 1}) {
    final current = activeChild;
    if (!current.isScreenTimeEnabled || current.isTemporarilyUnlocked) {
      return;
    }

    current.checkAndResetDaily();
    final wasLocked = current.isLimitReached;
    current.secondsUsedToday += seconds;
    final isNowLocked = current.isLimitReached;

    // Persist every 10 seconds or when state switches to locked
    if (isNowLocked != wasLocked || current.secondsUsedToday % 10 == 0) {
      _persist();
    }

    notifyListeners();
  }

  Future<void> addExtraMinutes(int extraMinutes) async {
    final current = activeChild;
    // Lower the used seconds by extraMinutes * 60, or increase dailyLimit
    final secondsToSubtract = extraMinutes * 60;
    if (current.secondsUsedToday >= secondsToSubtract) {
      current.secondsUsedToday -= secondsToSubtract;
    } else {
      current.secondsUsedToday = 0;
    }
    current.isTemporarilyUnlocked = false;
    await _persist();
    notifyListeners();
  }

  Future<void> unlockForToday() async {
    final current = activeChild;
    current.isTemporarilyUnlocked = true;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_children.map((c) => c.toJson()).toList());
      await prefs.setString(_keyChildrenList, encoded);
      if (_activeChildId != null) {
        await prefs.setString(_keyActiveChildId, _activeChildId!);
      }
    } catch (e) {
      debugPrint('ScreenTimeService persist error: $e');
    }
  }
}
