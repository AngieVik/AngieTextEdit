import 'package:flutter_test/flutter_test.dart';
import 'package:angie_text_edit/core/utils/text_utilities.dart';

void main() {
  group('TextUtilities - Case Transformations', () {
    test('toUpperCase converts text to uppercase', () {
      expect(TextUtilities.toUpperCase('hello world'), 'HELLO WORLD');
      expect(TextUtilities.toUpperCase('Hello'), 'HELLO');
      expect(TextUtilities.toUpperCase(''), '');
    });

    test('toLowerCase converts text to lowercase', () {
      expect(TextUtilities.toLowerCase('HELLO WORLD'), 'hello world');
      expect(TextUtilities.toLowerCase('Hello'), 'hello');
      expect(TextUtilities.toLowerCase(''), '');
    });

    test('toTitleCase capitalizes first letter of each word', () {
      expect(TextUtilities.toTitleCase('hello world'), 'Hello World');
      expect(TextUtilities.toTitleCase('HELLO WORLD'), 'Hello World');
      expect(TextUtilities.toTitleCase(''), '');
      expect(TextUtilities.toTitleCase('a'), 'A');
    });

    test('toSmartCase capitalizes after sentence endings', () {
      expect(TextUtilities.toSmartCase('hello. world'), 'Hello. World');
      expect(TextUtilities.toSmartCase('test! yes? ok.'), 'Test! Yes? Ok.');
      expect(TextUtilities.toSmartCase(''), '');
    });
  });

  group('TextUtilities - Text Cleanup', () {
    test('trim removes leading and trailing whitespace', () {
      expect(TextUtilities.trim('  hello  '), 'hello');
      expect(TextUtilities.trim('no spaces'), 'no spaces');
      expect(TextUtilities.trim(''), '');
    });

    test('removeDoubleSpaces replaces multiple spaces with single', () {
      expect(TextUtilities.removeDoubleSpaces('hello  world'), 'hello world');
      expect(TextUtilities.removeDoubleSpaces('a    b    c'), 'a b c');
      expect(TextUtilities.removeDoubleSpaces('single'), 'single');
    });

    test('removeEmptyLines removes blank lines', () {
      expect(TextUtilities.removeEmptyLines('a\n\nb'), 'a\nb');
      expect(TextUtilities.removeEmptyLines('a\n   \nb'), 'a\nb');
      expect(TextUtilities.removeEmptyLines('no empty'), 'no empty');
    });

    test('mergeParagraphs joins all lines', () {
      expect(TextUtilities.mergeParagraphs('a\nb\nc'), 'a b c');
      expect(TextUtilities.mergeParagraphs('  a  \n  b  '), 'a b');
    });
  });

  group('TextUtilities - Line Operations', () {
    test('deduplicateLines keeps only first occurrence', () {
      expect(TextUtilities.deduplicateLines('a\nb\na'), 'a\nb');
      expect(TextUtilities.deduplicateLines('x\nx\nx'), 'x');
    });

    test('sortLinesAZ sorts alphabetically', () {
      expect(TextUtilities.sortLinesAZ('c\na\nb'), 'a\nb\nc');
      expect(TextUtilities.sortLinesAZ('Banana\napple'), 'apple\nBanana');
    });

    test('sortLinesZA sorts reverse alphabetically', () {
      expect(TextUtilities.sortLinesZA('a\nb\nc'), 'c\nb\na');
    });

    test('reverseLines reverses line order', () {
      expect(TextUtilities.reverseLines('1\n2\n3'), '3\n2\n1');
    });

    test('numberLines adds line numbers', () {
      expect(TextUtilities.numberLines('a\nb'), '1. a\n2. b');
    });

    test('removeLineNumbers strips line numbers', () {
      expect(TextUtilities.removeLineNumbers('1. a\n2. b'), 'a\nb');
      expect(TextUtilities.removeLineNumbers('1) test'), 'test');
      expect(TextUtilities.removeLineNumbers('1- item'), 'item');
    });

    test('wrapText wraps at specified width', () {
      final result = TextUtilities.wrapText('hello world test', maxWidth: 10);
      expect(result.contains('\n'), true);
    });
  });

  group('TextUtilities - Counters', () {
    test('countWords returns correct word count', () {
      expect(TextUtilities.countWords('hello world'), 2);
      expect(TextUtilities.countWords('one'), 1);
      expect(TextUtilities.countWords(''), 0);
      expect(TextUtilities.countWords('   '), 0);
    });

    test('countCharacters returns total characters', () {
      expect(TextUtilities.countCharacters('hello'), 5);
      expect(TextUtilities.countCharacters('ab cd'), 5);
      expect(TextUtilities.countCharacters(''), 0);
    });

    test('countCharactersNoSpaces excludes spaces', () {
      expect(TextUtilities.countCharactersNoSpaces('ab cd'), 4);
      expect(TextUtilities.countCharactersNoSpaces('  a  '), 1);
    });

    test('countLines returns line count', () {
      expect(TextUtilities.countLines('a\nb\nc'), 3);
      expect(TextUtilities.countLines('single'), 1);
      expect(TextUtilities.countLines(''), 0);
    });

    test('countParagraphs counts paragraph blocks', () {
      expect(TextUtilities.countParagraphs('a\n\nb'), 2);
      expect(TextUtilities.countParagraphs('single'), 1);
      expect(TextUtilities.countParagraphs(''), 0);
    });
  });

  group('TextUtilities - Extractors', () {
    test('extractEmails finds email addresses', () {
      const text = 'Contact test@example.com or info@site.org';
      final emails = TextUtilities.extractEmails(text);
      expect(emails, ['test@example.com', 'info@site.org']);
    });

    test('extractEmails returns empty list when no emails', () {
      expect(TextUtilities.extractEmails('no emails here'), isEmpty);
    });

    test('extractUrls finds URLs', () {
      const text = 'Visit https://google.com or http://test.org';
      final urls = TextUtilities.extractUrls(text);
      expect(urls.length, 2);
      expect(urls[0], contains('google.com'));
    });

    test('extractPhoneNumbers finds phone numbers', () {
      const text = 'Call +1-555-123-4567 or (555) 987-6543';
      final phones = TextUtilities.extractPhoneNumbers(text);
      expect(phones.isNotEmpty, true);
    });
  });
}
