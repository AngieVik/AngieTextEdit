import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for local storage operations using SharedPreferences
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure initialized before operations
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // ============================================
  // DRAFT STORAGE
  // ============================================

  /// Save editor draft as Delta JSON
  Future<bool> saveDraft(List<dynamic> deltaJson) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(deltaJson);
      return await prefs.setString('editor_draft', jsonString);
    } catch (e) {
      debugPrint('Error saving draft: $e');
      return false;
    }
  }

  /// Load editor draft as Delta JSON
  Future<List<dynamic>?> loadDraft() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString('editor_draft');
      if (jsonString == null || jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return null;
    }
  }

  /// Clear the saved draft
  Future<bool> clearDraft() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.remove('editor_draft');
    } catch (e) {
      debugPrint('Error clearing draft: $e');
      return false;
    }
  }

  /// Check if a draft exists
  Future<bool> hasDraft() async {
    final prefs = await _getPrefs();
    return prefs.containsKey('editor_draft');
  }

  // ============================================
  // SETTINGS STORAGE
  // ============================================

  /// Save a string setting
  Future<bool> setString(String key, String value) async {
    final prefs = await _getPrefs();
    return await prefs.setString(key, value);
  }

  /// Get a string setting
  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  /// Save an int setting
  Future<bool> setInt(String key, int value) async {
    final prefs = await _getPrefs();
    return await prefs.setInt(key, value);
  }

  /// Get an int setting
  Future<int?> getInt(String key) async {
    final prefs = await _getPrefs();
    return prefs.getInt(key);
  }

  /// Save a bool setting
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _getPrefs();
    return await prefs.setBool(key, value);
  }

  /// Get a bool setting
  Future<bool?> getBool(String key) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key);
  }

  /// Save a double setting
  Future<bool> setDouble(String key, double value) async {
    final prefs = await _getPrefs();
    return await prefs.setDouble(key, value);
  }

  /// Get a double setting
  Future<double?> getDouble(String key) async {
    final prefs = await _getPrefs();
    return prefs.getDouble(key);
  }

  /// Save a string list
  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _getPrefs();
    return await prefs.setStringList(key, value);
  }

  /// Get a string list
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _getPrefs();
    return prefs.getStringList(key);
  }

  /// Save a JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final prefs = await _getPrefs();
    return await prefs.setString(key, jsonEncode(value));
  }

  /// Get a JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Remove a setting
  Future<bool> remove(String key) async {
    final prefs = await _getPrefs();
    return await prefs.remove(key);
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    final prefs = await _getPrefs();
    return prefs.containsKey(key);
  }

  /// Clear all settings (use with caution!)
  Future<bool> clear() async {
    final prefs = await _getPrefs();
    return await prefs.clear();
  }

  // ============================================
  // APP-SPECIFIC SETTINGS
  // ============================================

  /// Save theme mode preference
  Future<bool> saveThemeMode(String mode) async {
    return await setString('theme_mode', mode);
  }

  /// Get theme mode preference
  Future<String> getThemeMode() async {
    return await getString('theme_mode') ?? 'system';
  }

  /// Save TTS settings
  Future<bool> saveTtsSettings({
    double? rate,
    double? pitch,
    double? volume,
    String? language,
  }) async {
    final settings = <String, dynamic>{};
    if (rate != null) settings['rate'] = rate;
    if (pitch != null) settings['pitch'] = pitch;
    if (volume != null) settings['volume'] = volume;
    if (language != null) settings['language'] = language;
    return await setJson('tts_settings', settings);
  }

  /// Get TTS settings
  Future<Map<String, dynamic>?> getTtsSettings() async {
    return await getJson('tts_settings');
  }

  /// Save recent files list
  Future<bool> saveRecentFiles(List<String> paths) async {
    // Keep only last 10 files
    final trimmed = paths.take(10).toList();
    return await setStringList('recent_files', trimmed);
  }

  /// Get recent files list
  Future<List<String>> getRecentFiles() async {
    return await getStringList('recent_files') ?? [];
  }

  /// Add a file to recent files
  Future<bool> addRecentFile(String path) async {
    final files = await getRecentFiles();
    // Remove if already exists, then add to front
    files.remove(path);
    files.insert(0, path);
    return await saveRecentFiles(files);
  }
}
