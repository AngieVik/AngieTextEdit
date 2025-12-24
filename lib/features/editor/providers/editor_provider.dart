import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for the QuillController
final editorControllerProvider =
    StateNotifierProvider<EditorControllerNotifier, QuillController>((ref) {
  return EditorControllerNotifier();
});

/// Provider for document change stream (for auto-save)
final documentChangedProvider = StateProvider<int>((ref) => 0);

/// Provider for undo/redo availability
final canUndoProvider = Provider<bool>((ref) {
  final controller = ref.watch(editorControllerProvider);
  return controller.hasUndo;
});

final canRedoProvider = Provider<bool>((ref) {
  final controller = ref.watch(editorControllerProvider);
  return controller.hasRedo;
});

/// StateNotifier for managing the QuillController
class EditorControllerNotifier extends StateNotifier<QuillController> {
  EditorControllerNotifier() : super(_createDefaultController()) {
    _loadDraft();
  }

  static QuillController _createDefaultController() {
    return QuillController.basic();
  }

  /// Load draft from SharedPreferences
  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('editor_draft');
      if (draftJson != null && draftJson.isNotEmpty) {
        final deltaJson = jsonDecode(draftJson);
        final document = Document.fromJson(deltaJson);
        state = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (e) {
      // If loading fails, keep the default empty document
      // ignore: avoid_print
      print('Error loading draft: $e');
    }
  }

  /// Save current document to SharedPreferences
  Future<void> saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deltaJson = jsonEncode(state.document.toDelta().toJson());
      await prefs.setString('editor_draft', deltaJson);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving draft: $e');
    }
  }

  /// Clear the draft from storage
  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('editor_draft');
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing draft: $e');
    }
  }

  /// Create a new empty document
  void newDocument() {
    state = QuillController.basic();
  }

  /// Clear the document (alias for newDocument)
  void clearDocument() {
    newDocument();
  }

  /// Load a document from Delta JSON
  void loadDocument(List<dynamic> deltaJson) {
    try {
      final document = Document.fromJson(deltaJson);
      state = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error loading document: $e');
    }
  }

  /// Get the current document as Delta JSON
  List<dynamic> getDocumentJson() {
    return state.document.toDelta().toJson();
  }

  /// Get the current document as plain text
  String getPlainText() {
    return state.document.toPlainText();
  }

  /// Undo the last change
  void undo() {
    state.undo();
  }

  /// Redo the last undone change
  void redo() {
    state.redo();
  }

  /// Replace the entire document content with new text
  void replaceText(String newText) {
    final document = Document()..insert(0, newText);
    state = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  /// Apply a text transformation to the selected text or entire document
  void applyTransformation(String Function(String) transformation) {
    final selection = state.selection;
    final document = state.document;

    if (selection.isCollapsed) {
      // No selection - transform entire document
      final plainText = document.toPlainText();
      final transformed = transformation(plainText.trim());
      replaceText(transformed);
    } else {
      // Transform selected text
      final selectedText = document.getPlainText(
        selection.baseOffset,
        selection.extentOffset - selection.baseOffset,
      );
      final transformed = transformation(selectedText);
      
      // Replace the selected text
      state.replaceText(
        selection.baseOffset,
        selection.extentOffset - selection.baseOffset,
        transformed,
        null,
      );
    }
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}
