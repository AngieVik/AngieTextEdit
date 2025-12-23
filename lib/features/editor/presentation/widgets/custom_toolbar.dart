import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Custom toolbar widget for the rich text editor
/// Includes all formatting options: Bold, Italic, Underline, Headers, Alignment, Lists, Indent/Outdent
class CustomToolbar extends StatelessWidget {
  final QuillController controller;

  const CustomToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest.withAlpha(77),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: QuillSimpleToolbar(
        controller: controller,
        config: const QuillSimpleToolbarConfig(
          showBoldButton: true,
          showItalicButton: true,
          showUnderLineButton: true,
          showStrikeThrough: true,
          showHeaderStyle: true,
          showListNumbers: true,
          showListBullets: true,
          showListCheck: true,
          showCodeBlock: true,
          showQuote: true,
          showIndent: true,
          showLink: true,
          showClearFormat: true,
          showAlignmentButtons: true,
          showSmallButton: false,
          showColorButton: false,
          showBackgroundColorButton: false,
          showSearchButton: false,
          showSubscript: false,
          showSuperscript: false,
          showInlineCode: false,
          showFontFamily: false,
          showFontSize: false,
          showDirection: false,
          showUndo: false,
          showRedo: false,
        ),
      ),
    );
  }
}
