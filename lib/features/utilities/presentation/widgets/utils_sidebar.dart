import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/text_utilities.dart';

/// Sidebar widget for text processing utilities
class UtilsSidebar extends ConsumerStatefulWidget {
  final QuillController controller;

  const UtilsSidebar({
    super.key,
    required this.controller,
  });

  @override
  ConsumerState<UtilsSidebar> createState() => _UtilsSidebarState();
}

class _UtilsSidebarState extends ConsumerState<UtilsSidebar> {
  String _extractedContent = '';
  bool _showExtracted = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plainText = widget.controller.document.toPlainText();
    
    // Calculate stats
    final wordCount = TextUtilities.countWords(plainText);
    final charCount = TextUtilities.countCharacters(plainText);
    final charNoSpaces = TextUtilities.countCharactersNoSpaces(plainText);
    final lineCount = TextUtilities.countLines(plainText);

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            child: Row(
              children: [
                Icon(Icons.build, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Text Utilities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Stats Card
          _buildStatsCard(
            context,
            wordCount: wordCount,
            charCount: charCount,
            charNoSpaces: charNoSpaces,
            lineCount: lineCount,
          ),

          const Divider(height: 1),

          // Utilities List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Case Transformations
                _buildSectionHeader(context, 'Case Transformation'),
                _buildUtilityButton(
                  context,
                  icon: Icons.arrow_upward,
                  label: 'UPPERCASE',
                  onTap: () => _applyTransform(TextUtilities.toUpperCase),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.arrow_downward,
                  label: 'lowercase',
                  onTap: () => _applyTransform(TextUtilities.toLowerCase),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.title,
                  label: 'Title Case',
                  onTap: () => _applyTransform(TextUtilities.toTitleCase),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.auto_fix_high,
                  label: 'Smart Case',
                  onTap: () => _applyTransform(TextUtilities.toSmartCase),
                ),

                const SizedBox(height: 8),
                const Divider(),

                // Text Cleanup
                _buildSectionHeader(context, 'Text Cleanup'),
                _buildUtilityButton(
                  context,
                  icon: Icons.content_cut,
                  label: 'Trim Whitespace',
                  onTap: () => _applyTransform(TextUtilities.trim),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.space_bar,
                  label: 'Remove Double Spaces',
                  onTap: () => _applyTransform(TextUtilities.removeDoubleSpaces),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.remove,
                  label: 'Remove Empty Lines',
                  onTap: () => _applyTransform(TextUtilities.removeEmptyLines),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.merge,
                  label: 'Merge Paragraphs',
                  onTap: () => _applyTransform(TextUtilities.mergeParagraphs),
                ),

                const SizedBox(height: 8),
                const Divider(),

                // Line Operations
                _buildSectionHeader(context, 'Line Operations'),
                _buildUtilityButton(
                  context,
                  icon: Icons.filter_alt,
                  label: 'Deduplicate Lines',
                  onTap: () => _applyTransform(TextUtilities.deduplicateLines),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.sort_by_alpha,
                  label: 'Sort A → Z',
                  onTap: () => _applyTransform(TextUtilities.sortLinesAZ),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.sort_by_alpha,
                  label: 'Sort Z → A',
                  onTap: () => _applyTransform(TextUtilities.sortLinesZA),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.swap_vert,
                  label: 'Reverse Lines',
                  onTap: () => _applyTransform(TextUtilities.reverseLines),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.format_list_numbered,
                  label: 'Number Lines',
                  onTap: () => _applyTransform(TextUtilities.numberLines),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.format_list_bulleted,
                  label: 'Remove Line Numbers',
                  onTap: () => _applyTransform(TextUtilities.removeLineNumbers),
                ),

                const SizedBox(height: 8),
                const Divider(),

                // Extractors
                _buildSectionHeader(context, 'Extract Data'),
                _buildUtilityButton(
                  context,
                  icon: Icons.email,
                  label: 'Extract Emails',
                  onTap: () => _extractData(
                    TextUtilities.extractEmails,
                    'Emails',
                  ),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.link,
                  label: 'Extract URLs',
                  onTap: () => _extractData(
                    TextUtilities.extractUrls,
                    'URLs',
                  ),
                ),
                _buildUtilityButton(
                  context,
                  icon: Icons.phone,
                  label: 'Extract Phone Numbers',
                  onTap: () => _extractData(
                    TextUtilities.extractPhoneNumbers,
                    'Phone Numbers',
                  ),
                ),

                // Extracted Content Display
                if (_showExtracted && _extractedContent.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Extracted Results',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      _showExtracted = false;
                                      _extractedContent = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              _extractedContent,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required int wordCount,
    required int charCount,
    required int charNoSpaces,
    required int lineCount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      label: 'Words',
                      value: wordCount.toString(),
                      icon: Icons.text_fields,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      label: 'Characters',
                      value: charCount.toString(),
                      icon: Icons.abc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      label: 'No Spaces',
                      value: charNoSpaces.toString(),
                      icon: Icons.space_bar,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      label: 'Lines',
                      value: lineCount.toString(),
                      icon: Icons.format_line_spacing,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildUtilityButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13),
      ),
      onTap: onTap,
      hoverColor: colorScheme.primary.withAlpha(26),
    );
  }

  void _applyTransform(String Function(String) transform) {
    final plainText = widget.controller.document.toPlainText();
    final transformed = transform(plainText.trim());

    // Replace the entire document - modify in place
    widget.controller.document.delete(0, widget.controller.document.length - 1);
    widget.controller.document.insert(0, transformed);

    // Trigger rebuild for stats update
    setState(() {});

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transformation applied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _extractData(List<String> Function(String) extractor, String type) {
    final plainText = widget.controller.document.toPlainText();
    final results = extractor(plainText);

    setState(() {
      if (results.isEmpty) {
        _extractedContent = 'No $type found';
      } else {
        _extractedContent = results.join('\n');
      }
      _showExtracted = true;
    });
  }
}
