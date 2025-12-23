import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../services/file_service.dart';
import '../services/pdf_export_service.dart';
import '../services/html_export_service.dart';

/// Provider for export operations
final exportProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// Provider to track the current file path (if saved)
final currentFilePathProvider = StateProvider<String?>((ref) => null);

/// Provider to track if the document is new (never saved)
final isNewDocumentProvider = StateProvider<bool>((ref) => true);

/// Service class wrapping all export functionality
class ExportService {
  /// Save document with user-selected location
  Future<FileOperationResult> saveAs(
    Document document, {
    ExportFormat format = ExportFormat.txt,
    String? suggestedName,
  }) {
    return FileService.saveDocument(
      document,
      format: format,
      suggestedName: suggestedName,
    );
  }

  /// Quick save to app documents
  Future<FileOperationResult> quickSave(
    Document document, {
    required String fileName,
    ExportFormat format = ExportFormat.json,
  }) {
    return FileService.quickSave(
      document,
      fileName: fileName,
      format: format,
    );
  }

  /// Load a document from file
  Future<Document?> loadDocument() {
    return FileService.loadDocument();
  }

  /// Export to PDF and show preview
  Future<void> exportPdfPreview(
    Document document, {
    required dynamic context, // BuildContext
  }) {
    return PdfExportService.previewPdf(context, document);
  }

  /// Export to PDF and share
  Future<void> sharePdf(Document document, {String? filename}) {
    return PdfExportService.sharePdf(document, filename: filename);
  }

  /// Get HTML content from document
  String toHtml(Document document) {
    return HtmlExportService.documentToHtml(document);
  }

  /// Get full HTML document
  String toFullHtml(Document document, {String? title}) {
    return HtmlExportService.documentToFullHtml(
      document,
      title: title ?? 'Document',
    );
  }

  /// Get plain text from document
  String toPlainText(Document document) {
    return document.toPlainText();
  }
}
