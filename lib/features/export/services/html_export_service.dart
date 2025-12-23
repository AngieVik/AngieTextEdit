import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// Service for converting Quill documents to HTML
class HtmlExportService {
  HtmlExportService._();

  /// Convert a Quill document to HTML string
  static String documentToHtml(Document document) {
    final delta = document.toDelta();
    final deltaJson = delta.toJson();

    // Convert Delta operations to the format expected by vsc_quill_delta_to_html
    final ops = List<Map<String, dynamic>>.from(
      deltaJson.cast<Map<String, dynamic>>(),
    );

    final converter = QuillDeltaToHtmlConverter(
      List<Map<String, dynamic>>.from(ops),
      ConverterOptions(
        converterOptions: OpConverterOptions(
          inlineStylesFlag: true,
        ),
      ),
    );

    return converter.convert();
  }

  /// Convert a Quill document to a complete HTML document with head/body
  static String documentToFullHtml(
    Document document, {
    String title = 'Document',
    String? customCss,
  }) {
    final bodyContent = documentToHtml(document);

    const defaultCss = '''
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
        font-size: 16px;
        line-height: 1.6;
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
        color: #333;
      }
      h1 { font-size: 2em; margin-top: 1em; margin-bottom: 0.5em; }
      h2 { font-size: 1.5em; margin-top: 0.8em; margin-bottom: 0.4em; }
      h3 { font-size: 1.25em; margin-top: 0.6em; margin-bottom: 0.3em; }
      p { margin: 0.5em 0; }
      ul, ol { padding-left: 2em; }
      li { margin: 0.3em 0; }
      blockquote {
        margin: 1em 0;
        padding-left: 1em;
        border-left: 3px solid #ccc;
        color: #666;
        font-style: italic;
      }
      pre, code {
        font-family: 'Courier New', Courier, monospace;
        background-color: #f4f4f4;
        padding: 0.2em 0.4em;
        border-radius: 3px;
      }
      pre {
        padding: 1em;
        overflow-x: auto;
      }
      a {
        color: #0066cc;
        text-decoration: none;
      }
      a:hover {
        text-decoration: underline;
      }
    ''';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    ${customCss ?? defaultCss}
  </style>
</head>
<body>
  $bodyContent
</body>
</html>
''';
  }

  /// Convert plain text to basic HTML
  static String textToHtml(String text) {
    // Escape HTML special characters
    String escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

    // Convert newlines to paragraphs
    final paragraphs = escaped.split('\n\n');
    final htmlParagraphs = paragraphs
        .map((p) => '<p>${p.replaceAll('\n', '<br>')}</p>')
        .join('\n');

    return htmlParagraphs;
  }

  /// Strip HTML tags from content
  static String htmlToPlainText(String html) {
    // Remove script and style tags with their content
    String result = html.replaceAll(
      RegExp(r'<(script|style)[^>]*>.*?</\1>', caseSensitive: false, dotAll: true),
      '',
    );

    // Convert block elements to newlines
    result = result.replaceAll(
      RegExp(r'</?(p|div|br|h[1-6]|li)[^>]*>', caseSensitive: false),
      '\n',
    );

    // Remove remaining HTML tags
    result = result.replaceAll(RegExp(r'<[^>]+>'), '');

    // Decode HTML entities
    result = _decodeHtmlEntities(result);

    // Clean up multiple newlines
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
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
}
