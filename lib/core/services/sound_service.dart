import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _isInitialized = false;
  final Set<String> _missingSounds = <String>{};

  // Sound file paths
  // Note: assets are declared in pubspec.yaml as "assets/sounds/"
  static const String _clickSound = 'sounds/click.mp3';
  static const String _successSound = 'sounds/success.mp3';
  static const String _failSound = 'sounds/fail.mp3';
  static const String _winSound = 'sounds/win.mp3';
  static const String _starSound = 'sounds/star.mp3';

  /// Initialize sound service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      // Keep it lightweight; just set a default volume.
      await _audioPlayer.setVolume(1.0);
      _isInitialized = true;
      debugPrint('✅ Sound service initialized');
    } catch (e) {
      debugPrint('❌ Sound service initialization error: $e');
      // Continue without sound if initialization fails
    }
  }

  /// Enable or disable sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Play a sound from assets
  Future<void> _playSound(String soundPath) async {
    if (!_soundEnabled) return;
    if (_missingSounds.contains(soundPath)) return;

    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Stop any currently playing sound to avoid overlaps in quick taps.
      await _audioPlayer.stop();

      // audioplayers expects the asset key EXACTLY as in pubspec assets.
      // Since we included "assets/sounds/", we pass "sounds/..." OR "assets/sounds/..."
      // depending on your setup. In this repo we use full "assets/sounds/...".
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      // Silently fail - sound is not critical
      debugPrint('Error playing sound ($soundPath): $e');
      // Avoid spamming logs on every tap if the file is missing.
      if (e.toString().contains('Unable to load asset')) {
        _missingSounds.add(soundPath);
      }
    }
  }

  /// Play click sound
  Future<void> playClick() async {
    await _playSound(_clickSound);
  }

  /// Play success sound
  Future<void> playSuccess() async {
    await _playSound(_successSound);
  }

  /// Play fail sound
  Future<void> playFail() async {
    await _playSound(_failSound);
  }

  /// Play win sound
  Future<void> playWin() async {
    await _playSound(_winSound);
  }

  /// Play star sound
  Future<void> playStar() async {
    await _playSound(_starSound);
  }

  /// Stop all sounds
  Future<void> stopAll() async {
    await _audioPlayer.stop();
  }

  /// Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
