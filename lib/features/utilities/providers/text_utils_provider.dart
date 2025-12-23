import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/text_utilities.dart';

/// Provider for accessing text utilities
final textUtilsProvider = Provider<TextUtilitiesService>((ref) {
  return TextUtilitiesService();
});

/// Service wrapper for TextUtilities that can be injected via Riverpod
class TextUtilitiesService {
  // Case transformations
  String toUpperCase(String text) => TextUtilities.toUpperCase(text);
  String toLowerCase(String text) => TextUtilities.toLowerCase(text);
  String toTitleCase(String text) => TextUtilities.toTitleCase(text);
  String toSmartCase(String text) => TextUtilities.toSmartCase(text);

  // Text cleanup
  String trim(String text) => TextUtilities.trim(text);
  String removeDoubleSpaces(String text) => TextUtilities.removeDoubleSpaces(text);
  String removeEmptyLines(String text) => TextUtilities.removeEmptyLines(text);
  String mergeParagraphs(String text) => TextUtilities.mergeParagraphs(text);

  // Line operations
  String deduplicateLines(String text) => TextUtilities.deduplicateLines(text);
  String sortLinesAZ(String text) => TextUtilities.sortLinesAZ(text);
  String sortLinesZA(String text) => TextUtilities.sortLinesZA(text);
  String reverseLines(String text) => TextUtilities.reverseLines(text);
  String numberLines(String text) => TextUtilities.numberLines(text);
  String removeLineNumbers(String text) => TextUtilities.removeLineNumbers(text);
  String wrapText(String text, {int maxWidth = 80}) =>
      TextUtilities.wrapText(text, maxWidth: maxWidth);

  // Analyzers
  int countWords(String text) => TextUtilities.countWords(text);
  int countCharacters(String text) => TextUtilities.countCharacters(text);
  int countCharactersNoSpaces(String text) => TextUtilities.countCharactersNoSpaces(text);
  int countLines(String text) => TextUtilities.countLines(text);
  int countParagraphs(String text) => TextUtilities.countParagraphs(text);

  // Extractors
  List<String> extractEmails(String text) => TextUtilities.extractEmails(text);
  List<String> extractUrls(String text) => TextUtilities.extractUrls(text);
  List<String> extractPhoneNumbers(String text) => TextUtilities.extractPhoneNumbers(text);
}
