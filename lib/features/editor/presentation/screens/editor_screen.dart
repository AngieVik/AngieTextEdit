import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../widgets/custom_toolbar.dart';
import '../../providers/editor_provider.dart';
import '../../providers/auto_save_provider.dart';
import '../../../utilities/presentation/widgets/utils_sidebar.dart';

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

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _scrollController.dispose();
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
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleSave() {
    ref.read(autoSaveProvider).saveNow();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document saved'),
        duration: Duration(seconds: 1),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(editorControllerProvider);
    final hasUnsavedChanges = ref.watch(hasUnsavedChangesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Set up document change listener for auto-save
    controller.document.changes.listen((_) {
      ref.read(autoSaveProvider).documentChanged();
    });

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
            ],
          ),
          actions: [
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
            // Save button
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _handleSave,
              tooltip: 'Save (Ctrl+S)',
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
