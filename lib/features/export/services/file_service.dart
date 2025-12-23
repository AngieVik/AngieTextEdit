import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path_provider/path_provider.dart';
import 'html_export_service.dart';
import 'pdf_export_service.dart';

/// Supported file formats for export
enum ExportFormat { txt, html, json, pdf }

/// Result of a file operation
class FileOperationResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;

  FileOperationResult({
    required this.success,
    this.filePath,
    this.errorMessage,
  });

  factory FileOperationResult.success(String filePath) => FileOperationResult(
        success: true,
        filePath: filePath,
      );

  factory FileOperationResult.error(String message) => FileOperationResult(
        success: false,
        errorMessage: message,
      );
}

/// Service for file operations (save, load, export)
class FileService {
  FileService._();

  /// Save document to a file with user-selected location
  static Future<FileOperationResult> saveDocument(
    Document document, {
    ExportFormat format = ExportFormat.txt,
    String? suggestedName,
  }) async {
    try {
      String content;
      String extension;
      List<String>? allowedExtensions;

      switch (format) {
        case ExportFormat.txt:
          content = document.toPlainText();
          extension = 'txt';
          allowedExtensions = ['txt'];
          break;
        case ExportFormat.html:
          content = HtmlExportService.documentToFullHtml(document);
          extension = 'html';
          allowedExtensions = ['html', 'htm'];
          break;
        case ExportFormat.json:
          content = jsonEncode(document.toDelta().toJson());
          extension = 'json';
          allowedExtensions = ['json'];
          break;
        case ExportFormat.pdf:
          // PDF is handled separately
          final pdfData = await PdfExportService.generatePdf(document);
          return await _saveBinaryFile(
            pdfData,
            suggestedName: suggestedName ?? 'document',
            extension: 'pdf',
          );
      }

      final fileName = suggestedName ?? 'document';
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Document',
        fileName: '$fileName.$extension',
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result == null) {
        return FileOperationResult.error('Save cancelled');
      }

      final file = File(result);
      await file.writeAsString(content, encoding: utf8);

      return FileOperationResult.success(result);
    } catch (e) {
      debugPrint('Error saving document: $e');
      return FileOperationResult.error('Failed to save: $e');
    }
  }

  /// Save binary data to a file
  static Future<FileOperationResult> _saveBinaryFile(
    Uint8List data, {
    required String suggestedName,
    required String extension,
  }) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Document',
        fileName: '$suggestedName.$extension',
        type: FileType.custom,
        allowedExtensions: [extension],
      );

      if (result == null) {
        return FileOperationResult.error('Save cancelled');
      }

      final file = File(result);
      await file.writeAsBytes(data);

      return FileOperationResult.success(result);
    } catch (e) {
      return FileOperationResult.error('Failed to save: $e');
    }
  }

  /// Load a document from a file
  static Future<Document?> loadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Open Document',
        type: FileType.custom,
        allowedExtensions: ['txt', 'html', 'htm', 'json', 'md'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.first.path!);
      final content = await file.readAsString(encoding: utf8);
      final extension = result.files.first.extension?.toLowerCase();

      switch (extension) {
        case 'json':
          // Load as Delta JSON
          try {
            final deltaJson = jsonDecode(content) as List<dynamic>;
            return Document.fromJson(deltaJson);
          } catch (_) {
            // If JSON parsing fails, treat as plain text
            return Document()..insert(0, content);
          }
        case 'html':
        case 'htm':
          // Convert HTML to plain text (simplified)
          final plainText = HtmlExportService.htmlToPlainText(content);
          return Document()..insert(0, plainText);
        case 'txt':
        case 'md':
        default:
          // Load as plain text
          return Document()..insert(0, content);
      }
    } catch (e) {
      debugPrint('Error loading document: $e');
      return null;
    }
  }

  /// Get the default documents directory path
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Quick save to app documents directory
  static Future<FileOperationResult> quickSave(
    Document document, {
    required String fileName,
    ExportFormat format = ExportFormat.json,
  }) async {
    try {
      final docsPath = await getDocumentsPath();
      String extension;
      String content;

      switch (format) {
        case ExportFormat.txt:
          extension = 'txt';
          content = document.toPlainText();
          break;
        case ExportFormat.html:
          extension = 'html';
          content = HtmlExportService.documentToFullHtml(document);
          break;
        case ExportFormat.json:
          extension = 'json';
          content = jsonEncode(document.toDelta().toJson());
          break;
        case ExportFormat.pdf:
          extension = 'pdf';
          final pdfData = await PdfExportService.generatePdf(document);
          final filePath = '$docsPath/$fileName.$extension';
          final file = File(filePath);
          await file.writeAsBytes(pdfData);
          return FileOperationResult.success(filePath);
      }

      final filePath = '$docsPath/$fileName.$extension';
      final file = File(filePath);
      await file.writeAsString(content, encoding: utf8);

      return FileOperationResult.success(filePath);
    } catch (e) {
      debugPrint('Error quick saving: $e');
      return FileOperationResult.error('Failed to save: $e');
    }
  }

  /// Check if a file exists
  static Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  /// Delete a file
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
}
