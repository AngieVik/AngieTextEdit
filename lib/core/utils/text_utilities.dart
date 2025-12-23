/// Pure Dart text utility functions
/// All methods are static and operate on plain strings
class TextUtilities {
  TextUtilities._();

  /// Convert text to uppercase
  static String toUpperCase(String text) => text.toUpperCase();

  /// Convert text to lowercase
  static String toLowerCase(String text) => text.toLowerCase();

  /// Convert text to title case (capitalize first letter of each word)
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Convert text to smart case (sentence case - capitalize after periods)
  static String toSmartCase(String text) {
    if (text.isEmpty) return text;

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (capitalizeNext && RegExp(r'[a-zA-Z]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char.toLowerCase());
      }

      if (char == '.' || char == '!' || char == '?') {
        capitalizeNext = true;
      }
    }

    return buffer.toString();
  }

  /// Remove leading and trailing whitespace
  static String trim(String text) => text.trim();

  /// Replace multiple spaces with a single space
  static String removeDoubleSpaces(String text) {
    return text.replaceAll(RegExp(r' {2,}'), ' ');
  }

  /// Remove empty lines from text
  static String removeEmptyLines(String text) {
    return text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .join('\n');
  }

  /// Merge all paragraphs into a single line
  static String mergeParagraphs(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join(' ');
  }

  /// Remove duplicate lines, keeping only the first occurrence
  static String deduplicateLines(String text) {
    final seen = <String>{};
    return text
        .split('\n')
        .where((line) => seen.add(line))
        .join('\n');
  }

  /// Sort lines alphabetically (A-Z)
  static String sortLinesAZ(String text) {
    final lines = text.split('\n');
    lines.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return lines.join('\n');
  }

  /// Sort lines in reverse alphabetical order (Z-A)
  static String sortLinesZA(String text) {
    final lines = text.split('\n');
    lines.sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
    return lines.join('\n');
  }

  /// Count the number of words in text
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Count the number of characters in text (including spaces)
  static int countCharacters(String text) => text.length;

  /// Count the number of characters in text (excluding spaces)
  static int countCharactersNoSpaces(String text) {
    return text.replaceAll(RegExp(r'\s'), '').length;
  }

  /// Count the number of lines in text
  static int countLines(String text) {
    if (text.isEmpty) return 0;
    return text.split('\n').length;
  }

  /// Count the number of paragraphs in text
  static int countParagraphs(String text) {
    if (text.trim().isEmpty) return 0;
    return text
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;
  }

  /// Extract all email addresses from text using regex
  static List<String> extractEmails(String text) {
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    return emailRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// Extract all URLs from text using regex
  static List<String> extractUrls(String text) {
    final urlRegex = RegExp(
      r'https?://[^\s<>\[\]{}|\\^`"]+',
      caseSensitive: false,
    );
    return urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// Extract all phone numbers from text (various formats)
  static List<String> extractPhoneNumbers(String text) {
    final phoneRegex = RegExp(
      r'[\+]?[(]?[0-9]{1,3}[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?[-\s\.]?[0-9]{3,6}[-\s\.]?[0-9]{3,6}',
    );
    return phoneRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// Reverse the order of lines
  static String reverseLines(String text) {
    return text.split('\n').reversed.join('\n');
  }

  /// Number each line (1. Line one, 2. Line two, etc.)
  static String numberLines(String text) {
    final lines = text.split('\n');
    return lines.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
  }

  /// Remove line numbers if present
  static String removeLineNumbers(String text) {
    return text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^\d+[\.\)\-\:]\s*'), ''))
        .join('\n');
  }

  /// Wrap text at specified column width
  static String wrapText(String text, {int maxWidth = 80}) {
    final words = text.split(' ');
    final buffer = StringBuffer();
    int currentLineLength = 0;

    for (final word in words) {
      if (currentLineLength + word.length + 1 > maxWidth && currentLineLength > 0) {
        buffer.write('\n');
        currentLineLength = 0;
      } else if (currentLineLength > 0) {
        buffer.write(' ');
        currentLineLength += 1;
      }
      buffer.write(word);
      currentLineLength += word.length;
    }

    return buffer.toString();
  }
}
