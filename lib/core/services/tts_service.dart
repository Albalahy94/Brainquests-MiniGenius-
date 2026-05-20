import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.45); // Slower for kids to understand easily
      await _flutterTts.setPitch(1.2); // Slightly higher pitch for a friendly tone
      
      _isInitialized = true;
      debugPrint('✅ TTS Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing TTS: $e');
    }
  }

  Future<void> speak(String text, String languageCode) async {
    if (!_isInitialized) await init();
    
    try {
      // Set language (e.g. 'ar-SA' or 'en-US')
      if (languageCode == 'ar') {
        await _flutterTts.setLanguage("ar-SA");
      } else {
        await _flutterTts.setLanguage("en-US");
      }

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ Error speaking TTS: $e');
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('❌ Error stopping TTS: $e');
    }
  }
}
