import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Handles clipboard paste events and converts HTML to Quill Delta
class ClipboardHandler {
  ClipboardHandler._();

  /// Process clipboard data and convert HTML to Delta if detected
  /// Returns the processed text or null if no valid content
  static Future<String?> processClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      debugPrint('Error processing clipboard: $e');
      return null;
    }
  }

  /// Check if clipboard contains HTML content
  static Future<bool> hasHtmlContent() async {
    try {
      // Note: Flutter's Clipboard API doesn't directly support HTML detection
      // This is a simplified implementation
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!;
        return _looksLikeHtml(text);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if text looks like HTML
  static bool _looksLikeHtml(String text) {
    final htmlPattern = RegExp(
      r'<\s*(html|body|div|p|span|a|b|i|u|strong|em|h[1-6]|ul|ol|li|br|table|tr|td)[^>]*>',
      caseSensitive: false,
    );
    return htmlPattern.hasMatch(text);
  }

  /// Convert simple HTML to Quill Delta operations
  /// This is a basic implementation - for full HTML support,
  /// consider using a dedicated HTML-to-Delta converter library
  static List<Map<String, dynamic>> htmlToDeltaOps(String html) {
    final ops = <Map<String, dynamic>>[];

    // Strip HTML tags and extract text (simplified conversion)
    // For production, use a proper HTML parser like html or flutter_html
    String plainText = html;

    // Remove script and style tags
    plainText = plainText.replaceAll(
      RegExp(r'<(script|style)[^>]*>.*?</\1>', caseSensitive: false, dotAll: true),
      '',
    );

    // Convert common block elements to newlines
    plainText = plainText.replaceAll(RegExp(r'</?(p|div|br|h[1-6])[^>]*>', caseSensitive: false), '\n');

    // Convert list items
    plainText = plainText.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ');
    plainText = plainText.replaceAll(RegExp(r'</li>', caseSensitive: false), '');

    // Remove remaining HTML tags
    plainText = plainText.replaceAll(RegExp(r'<[^>]+>'), '');

    // Decode HTML entities
    plainText = _decodeHtmlEntities(plainText);

    // Clean up multiple newlines
    plainText = plainText.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    plainText = plainText.trim();

    if (plainText.isNotEmpty) {
      ops.add({'insert': '$plainText\n'});
    } else {
      ops.add({'insert': '\n'});
    }

    return ops;
  }

  /// Decode common HTML entities
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }

  /// Create a Document from HTML string
  static Document? createDocumentFromHtml(String html) {
    try {
      final ops = htmlToDeltaOps(html);
      return Document.fromJson(ops);
    } catch (e) {
      debugPrint('Error creating document from HTML: $e');
      return null;
    }
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
