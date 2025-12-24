import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../widgets/custom_toolbar.dart';
import '../../providers/editor_provider.dart';
import '../../providers/auto_save_provider.dart';
import '../../../utilities/presentation/widgets/utils_sidebar.dart';
import '../../../export/services/file_service.dart';
import '../../../../shared/services/tts_service.dart';
import 'package:share_plus/share_plus.dart';

/// Main editor screen with rich text editor and utilities sidebar
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showSidebar = false;
  String? _currentFilePath;
  late final TtsService _ttsService;
  bool _isSpeaking = false;
  StreamSubscription? _documentChangesSubscription;

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService.instance;
    _ttsService.initialize();

    // Set up document change listener for auto-save after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(editorControllerProvider);
      _documentChangesSubscription = controller.document.changes.listen((_) {
        ref.read(autoSaveProvider).documentChanged();
      });
    });
  }

  @override
  void dispose() {
    _documentChangesSubscription?.cancel();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  /// Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrl = HardwareKeyboard.instance.isControlPressed;
      final isMeta = HardwareKeyboard.instance.isMetaPressed;
      final isModifier = isCtrl || isMeta;

      if (isModifier) {
        // Ctrl+S / Cmd+S - Save
        if (event.logicalKey == LogicalKeyboardKey.keyS) {
          _handleSave();
          return KeyEventResult.handled;
        }
        // Ctrl+Z / Cmd+Z - Undo
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            _handleRedo();
          } else {
            _handleUndo();
          }
          return KeyEventResult.handled;
        }
        // Ctrl+Y / Cmd+Y - Redo
        if (event.logicalKey == LogicalKeyboardKey.keyY) {
          _handleRedo();
          return KeyEventResult.handled;
        }
        // Ctrl+N / Cmd+N - New
        if (event.logicalKey == LogicalKeyboardKey.keyN) {
          _handleNew();
          return KeyEventResult.handled;
        }
        // Ctrl+O / Cmd+O - Open
        if (event.logicalKey == LogicalKeyboardKey.keyO) {
          _handleOpen();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleSave() {
    ref.read(autoSaveProvider).saveNow();
    _showSnackBar('Document saved');
  }

  void _handleUndo() {
    ref.read(editorControllerProvider.notifier).undo();
  }

  void _handleRedo() {
    ref.read(editorControllerProvider.notifier).redo();
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILE OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  void _handleNew() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Document'),
        content:
            const Text('Create a new document? Unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(editorControllerProvider.notifier).clearDocument();
              setState(() => _currentFilePath = null);
              _showSnackBar('New document created');
            },
            child: const Text('New'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpen() async {
    try {
      final document = await FileService.loadDocument();
      if (document != null) {
        final delta = document.toDelta().toJson();
        ref.read(editorControllerProvider.notifier).loadDocument(delta);
        _showSnackBar('Document opened');
      }
    } catch (e) {
      _showSnackBar('Error opening file: $e');
    }
  }

  Future<void> _handleSaveAs(String format) async {
    try {
      final controller = ref.read(editorControllerProvider);

      ExportFormat exportFormat;
      switch (format) {
        case 'txt':
          exportFormat = ExportFormat.txt;
          break;
        case 'html':
          exportFormat = ExportFormat.html;
          break;
        case 'json':
          exportFormat = ExportFormat.json;
          break;
        case 'pdf':
          exportFormat = ExportFormat.pdf;
          break;
        default:
          exportFormat = ExportFormat.txt;
      }

      final result = await FileService.saveDocument(
        controller.document,
        format: exportFormat,
      );

      if (result.success) {
        setState(() => _currentFilePath = result.filePath);
        _showSnackBar('Saved as $format');
      } else {
        _showSnackBar(result.errorMessage ?? 'Save failed');
      }
    } catch (e) {
      _showSnackBar('Error saving file: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARE & TTS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _handleShare() async {
    final controller = ref.read(editorControllerProvider);
    final text = controller.document.toPlainText();

    if (text.trim().isEmpty) {
      _showSnackBar('Nothing to share');
      return;
    }

    await Share.share(text, subject: 'Shared from Angie Text Edit');
  }

  Future<void> _toggleTts() async {
    final controller = ref.read(editorControllerProvider);

    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      final text = controller.document.toPlainText();
      if (text.trim().isEmpty) {
        _showSnackBar('No text to read');
        return;
      }
      await _ttsService.speak(text);
      setState(() => _isSpeaking = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(editorControllerProvider);
    final hasUnsavedChanges = ref.watch(hasUnsavedChangesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Angie Text Edit'),
              if (hasUnsavedChanges) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              if (_currentFilePath != null) ...[
                const SizedBox(width: 8),
                Text(
                  '- ${_currentFilePath!.split(RegExp(r'[/\\]')).last}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            // File menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.folder_outlined),
              tooltip: 'File',
              onSelected: (value) {
                switch (value) {
                  case 'new':
                    _handleNew();
                    break;
                  case 'open':
                    _handleOpen();
                    break;
                  case 'save':
                    _handleSave();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'new',
                    child: ListTile(
                        leading: Icon(Icons.add),
                        title: Text('New'),
                        subtitle: Text('Ctrl+N'))),
                const PopupMenuItem(
                    value: 'open',
                    child: ListTile(
                        leading: Icon(Icons.folder_open),
                        title: Text('Open'),
                        subtitle: Text('Ctrl+O'))),
                const PopupMenuItem(
                    value: 'save',
                    child: ListTile(
                        leading: Icon(Icons.save),
                        title: Text('Save Draft'),
                        subtitle: Text('Ctrl+S'))),
              ],
            ),

            // Export menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Export',
              onSelected: (value) => _handleSaveAs(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'txt',
                    child: ListTile(
                        leading: Icon(Icons.text_snippet),
                        title: Text('Export as TXT'))),
                const PopupMenuItem(
                    value: 'html',
                    child: ListTile(
                        leading: Icon(Icons.code),
                        title: Text('Export as HTML'))),
                const PopupMenuItem(
                    value: 'json',
                    child: ListTile(
                        leading: Icon(Icons.data_object),
                        title: Text('Export as JSON'))),
                const PopupMenuItem(
                    value: 'pdf',
                    child: ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('Export as PDF'))),
              ],
            ),

            const VerticalDivider(),

            // Undo button
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: ref.watch(canUndoProvider) ? _handleUndo : null,
              tooltip: 'Undo (Ctrl+Z)',
            ),
            // Redo button
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: ref.watch(canRedoProvider) ? _handleRedo : null,
              tooltip: 'Redo (Ctrl+Y)',
            ),

            const VerticalDivider(),

            // TTS button
            IconButton(
              icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
              onPressed: _toggleTts,
              tooltip: _isSpeaking ? 'Stop Reading' : 'Read Aloud',
            ),

            // Share button
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _handleShare,
              tooltip: 'Share',
            ),

            // Toggle sidebar button
            IconButton(
              icon: Icon(_showSidebar ? Icons.menu_open : Icons.menu),
              onPressed: _toggleSidebar,
              tooltip: 'Toggle Utilities',
            ),
          ],
        ),
        body: Column(
          children: [
            // Custom Toolbar
            CustomToolbar(controller: controller),

            // Divider
            const Divider(height: 1),

            // Editor and Sidebar
            Expanded(
              child: Row(
                children: [
                  // Editor
                  Expanded(
                    child: QuillEditor.basic(
                      controller: controller,
                      focusNode: _editorFocusNode,
                      scrollController: _scrollController,
                      config: const QuillEditorConfig(
                        // Enable all interactive features
                        enableInteractiveSelection: true,
                        enableSelectionToolbar: true,

                        // Enable clipboard operations
                        disableClipboard: false,

                        // Visual settings
                        padding: EdgeInsets.all(16),
                        placeholder: 'Start typing...',

                        // Auto focus disabled (focus managed manually)
                        autoFocus: false,
                      ),
                    ),
                  ),

                  // Sidebar
                  if (_showSidebar) ...[
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 280,
                      child: UtilsSidebar(controller: controller),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
