import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Service for exporting Quill documents to PDF
/// Converts Delta operations to PDF widgets (not screenshots)
class PdfExportService {
  PdfExportService._();

  /// Generate a PDF from a Quill document
  static Future<Uint8List> generatePdf(Document document) async {
    final pdf = pw.Document();
    final content = _convertDocumentToPdfWidgets(document);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => content,
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Convert Quill document to PDF widgets
  static List<pw.Widget> _convertDocumentToPdfWidgets(Document document) {
    final widgets = <pw.Widget>[];
    final delta = document.toDelta();

    // Parse Delta operations and convert to PDF widgets
    for (final op in delta.toList()) {
      if (op.data is String) {
        final text = op.data as String;
        final attributes = op.attributes;

        // Skip if just a newline with no content
        if (text == '\n' && (attributes == null || attributes.isEmpty)) {
          widgets.add(pw.SizedBox(height: 8));
          continue;
        }

        // Build text style based on attributes
        pw.TextStyle style = _buildTextStyle(attributes);

        // Check for block-level attributes
        if (attributes != null) {
          // Headers
          if (attributes.containsKey('header')) {
            final level = attributes['header'] as int;
            style = _getHeaderStyle(level);
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8, top: 12),
                child: pw.Text(text.trim(), style: style),
              ),
            );
            continue;
          }

          // Lists
          if (attributes.containsKey('list')) {
            final listType = attributes['list'] as String;
            widgets.add(_buildListItem(text.trim(), listType, style));
            continue;
          }

          // Block quote
          if (attributes.containsKey('blockquote')) {
            widgets.add(_buildBlockQuote(text.trim(), style));
            continue;
          }

          // Code block
          if (attributes.containsKey('code-block')) {
            widgets.add(_buildCodeBlock(text.trim()));
            continue;
          }
        }

        // Regular paragraph
        if (text.trim().isNotEmpty) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(text.trim(), style: style),
            ),
          );
        }
      }
    }

    return widgets;
  }

  /// Build text style from Delta attributes
  static pw.TextStyle _buildTextStyle(Map<String, dynamic>? attributes) {
    pw.FontWeight fontWeight = pw.FontWeight.normal;
    pw.FontStyle fontStyle = pw.FontStyle.normal;
    pw.TextDecoration? decoration;
    double fontSize = 12;
    PdfColor color = PdfColors.black;

    if (attributes != null) {
      if (attributes['bold'] == true) {
        fontWeight = pw.FontWeight.bold;
      }
      if (attributes['italic'] == true) {
        fontStyle = pw.FontStyle.italic;
      }
      if (attributes['underline'] == true) {
        decoration = pw.TextDecoration.underline;
      }
      if (attributes['strike'] == true) {
        decoration = pw.TextDecoration.lineThrough;
      }
      if (attributes.containsKey('size')) {
        // Handle font size if specified
        final sizeValue = attributes['size'];
        if (sizeValue is String) {
          fontSize = double.tryParse(sizeValue.replaceAll('px', '')) ?? 12;
        }
      }
      if (attributes.containsKey('color')) {
        // Handle text color if specified
        final colorValue = attributes['color'] as String?;
        if (colorValue != null) {
          color = _parseColor(colorValue);
        }
      }
    }

    return pw.TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      color: color,
      lineSpacing: 1.5,
    );
  }

  /// Get header style based on level
  static pw.TextStyle _getHeaderStyle(int level) {
    switch (level) {
      case 1:
        return pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
          lineSpacing: 1.3,
        );
      case 2:
        return pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          lineSpacing: 1.3,
        );
      case 3:
        return pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          lineSpacing: 1.3,
        );
      default:
        return pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          lineSpacing: 1.3,
        );
    }
  }

  /// Build a list item widget
  static pw.Widget _buildListItem(
      String text, String listType, pw.TextStyle style) {
    String bullet;
    if (listType == 'ordered') {
      bullet = '1.'; // Note: This is simplified; real implementation would track numbering
    } else if (listType == 'checked') {
      bullet = '☑';
    } else if (listType == 'unchecked') {
      bullet = '☐';
    } else {
      bullet = '•';
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 20,
            child: pw.Text(bullet, style: style),
          ),
          pw.Expanded(
            child: pw.Text(text, style: style),
          ),
        ],
      ),
    );
  }

  /// Build a block quote widget
  static pw.Widget _buildBlockQuote(String text, pw.TextStyle style) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.only(left: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColors.grey400,
            width: 3,
          ),
        ),
      ),
      child: pw.Text(
        text,
        style: style.copyWith(
          color: PdfColors.grey700,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  /// Build a code block widget
  static pw.Widget _buildCodeBlock(String text) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          font: pw.Font.courier(),
          lineSpacing: 1.4,
        ),
      ),
    );
  }

  /// Parse color string to PdfColor
  static PdfColor _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      try {
        final hex = colorString.substring(1);
        if (hex.length == 6) {
          final r = int.parse(hex.substring(0, 2), radix: 16);
          final g = int.parse(hex.substring(2, 4), radix: 16);
          final b = int.parse(hex.substring(4, 6), radix: 16);
          return PdfColor.fromInt(0xFF000000 | (r << 16) | (g << 8) | b);
        }
      } catch (_) {}
    }
    return PdfColors.black;
  }

  /// Preview the PDF
  static Future<void> previewPdf(
    BuildContext context,
    Document document,
  ) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generatePdf(document),
      name: 'Document Export',
    );
  }

  /// Share the PDF
  static Future<void> sharePdf(Document document, {String? filename}) async {
    final pdfData = await generatePdf(document);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: filename ?? 'document.pdf',
    );
  }
}
