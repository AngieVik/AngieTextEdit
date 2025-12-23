import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'editor_provider.dart';

/// Auto-save debounce duration in milliseconds
const int _autoSaveDebounceMs = 2000;

/// Provider that manages auto-save functionality with debounce
final autoSaveProvider = Provider<AutoSaveService>((ref) {
  final service = AutoSaveService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider to track if there are unsaved changes
final hasUnsavedChangesProvider = StateProvider<bool>((ref) => false);

/// Provider to track the last save timestamp
final lastSavedProvider = StateProvider<DateTime?>((ref) => null);

/// Service class for managing auto-save with debounce
class AutoSaveService {
  final Ref _ref;
  Timer? _debounceTimer;
  bool _disposed = false;

  AutoSaveService(this._ref);

  /// Mark the document as changed and schedule auto-save
  void documentChanged() {
    if (_disposed) return;

    // Mark as having unsaved changes
    _ref.read(hasUnsavedChangesProvider.notifier).state = true;

    // Cancel existing timer
    _debounceTimer?.cancel();

    // Schedule new save after debounce period
    _debounceTimer = Timer(
      const Duration(milliseconds: _autoSaveDebounceMs),
      _performSave,
    );
  }

  /// Perform the actual save operation
  Future<void> _performSave() async {
    if (_disposed) return;

    try {
      await _ref.read(editorControllerProvider.notifier).saveDraft();
      
      if (!_disposed) {
        _ref.read(hasUnsavedChangesProvider.notifier).state = false;
        _ref.read(lastSavedProvider.notifier).state = DateTime.now();
      }
    } catch (e) {
      // Log error but don't crash
      // ignore: avoid_print
      print('Auto-save error: $e');
    }
  }

  /// Force an immediate save (bypasses debounce)
  Future<void> saveNow() async {
    if (_disposed) return;

    _debounceTimer?.cancel();
    await _performSave();
  }

  /// Dispose of resources
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
