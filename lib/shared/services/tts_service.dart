import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for text-to-speech functionality
class TtsService {
  static TtsService? _instance;
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  TtsService._();

  static TtsService get instance {
    _instance ??= TtsService._();
    return _instance!;
  }

  /// Initialize TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Set default language
      await _flutterTts.setLanguage('en-US');

      // Set default speech rate (0.0 - 1.0, 0.5 is normal)
      await _flutterTts.setSpeechRate(0.5);

      // Set pitch (0.5 - 2.0, 1.0 is normal)
      await _flutterTts.setPitch(1.0);

      // Set volume (0.0 - 1.0)
      await _flutterTts.setVolume(1.0);

      // Set up completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Set up error handler
      _flutterTts.setErrorHandler((message) {
        debugPrint('TTS Error: $message');
        _isSpeaking = false;
      });

      // Set up start handler
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      // Platform-specific setup
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterTts.awaitSpeakCompletion(true);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Stop any current speech first
      if (_isSpeaking) {
        await stop();
      }

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Pause speaking (only supported on some platforms)
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setLanguage(languageCode);
  }

  /// Get available languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages ?? []);
    } catch (e) {
      debugPrint('TTS getLanguages error: $e');
      return [];
    }
  }

  /// Get available voices
  Future<List<Map<String, String>>> getVoices() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      final voices = await _flutterTts.getVoices;
      return List<Map<String, String>>.from(
        (voices ?? []).map((v) => Map<String, String>.from(v)),
      );
    } catch (e) {
      debugPrint('TTS getVoices error: $e');
      return [];
    }
  }

  /// Set voice
  Future<void> setVoice(Map<String, String> voice) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.setVoice(voice);
  }

  /// Dispose of TTS resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await stop();
      _isInitialized = false;
    }
  }
}
