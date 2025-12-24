# AngieTextEdit - Project Rules

> **Purpose**: This document defines coding standards, architecture patterns, and conventions for consistent development.

---

## 📱 App Overview

**AngieTextEdit** is a cross-platform Rich Text Editor built with Flutter, targeting:

- Windows (primary)
- Android
- iOS
- Web (secondary)

### Core Functionality

- Rich text editing with `flutter_quill`
- 20+ text utilities (case transforms, cleanup, extractors)
- Export to TXT, HTML, JSON, PDF
- Auto-save drafts
- Text-to-Speech accessibility

---

## 🏗️ Architecture

### Pattern: Feature-First + Clean Architecture

```
lib/
├── main.dart              # Entry point with ProviderScope
├── app.dart               # MaterialApp configuration
├── core/                  # App-wide utilities (no feature logic)
│   ├── constants/         # Colors, dimensions, strings
│   ├── theme/             # ThemeData (light/dark)
│   └── utils/             # Pure Dart utilities (TextUtilities)
├── features/              # Feature modules (self-contained)
│   ├── editor/
│   │   ├── presentation/
│   │   │   ├── screens/   # Full-page widgets
│   │   │   └── widgets/   # Feature-specific widgets
│   │   └── providers/     # Riverpod state management
│   ├── export/
│   │   └── services/      # PDF, HTML, File services
│   └── utilities/
│       ├── presentation/
│       └── providers/
└── shared/                # Cross-feature code
    ├── services/          # TTS, Permissions, Storage
    └── widgets/           # Reusable UI components
```

### Rules

1. **Features are self-contained**: Each feature has its own `presentation/`, `providers/`, and optionally `services/`.
2. **No cross-feature imports**: Features should not import from other features directly. Use `shared/` for shared logic.
3. **Core has no dependencies**: `core/` must not import from `features/` or `shared/`.

---

## 🎯 State Management

### Library: `flutter_riverpod` ^2.6.0

### Patterns

#### StateNotifierProvider (Complex State)

```dart
final editorControllerProvider =
    StateNotifierProvider<EditorControllerNotifier, QuillController>((ref) {
  return EditorControllerNotifier();
});
```

#### StateProvider (Simple State)

```dart
final hasUnsavedChangesProvider = StateProvider<bool>((ref) => false);
```

#### Provider (Computed Values)

```dart
final canUndoProvider = Provider<bool>((ref) {
  final controller = ref.watch(editorControllerProvider);
  return controller.hasUndo;
});
```

### Rules

1. **Use StateNotifier for complex state** with multiple methods.
2. **Use StateProvider for simple flags** (booleans, counters).
3. **Always use `ref.watch()` in build methods**, `ref.read()` in callbacks.
4. **Providers go in `providers/` folder** within their feature.

---

## 🎨 UI & Theming

### Design System: Material 3

#### Theme Location

```
lib/core/theme/app_theme.dart
```

#### Color Palette

```dart
// Primary: Deep Purple (#6B21A8)
// Secondary: Pink (#EC4899)
// See: lib/core/constants/app_colors.dart
```

### Rules

1. **Use Theme.of(context)** for colors, not hardcoded values.
2. **Use `colorScheme` properties** (primary, secondary, surface, etc.).
3. **Avoid deprecated `withOpacity()`**, use `withAlpha()` instead.
4. **CardThemeData** not CardTheme when defining themes.

---

## 📦 Dependencies

### Core Stack

| Category    | Package              | Version           | Purpose           |
| ----------- | -------------------- | ----------------- | ----------------- |
| Editor      | `flutter_quill`      | ^11.5.0           | Rich text editing |
| State       | `flutter_riverpod`   | ^2.6.0            | Reactive state    |
| Storage     | `shared_preferences` | ^2.3.2            | Local persistence |
| Files       | `file_picker`        | ^8.0.0            | File dialogs      |
| PDF         | `pdf` + `printing`   | ^3.10.0 / ^5.11.0 | PDF generation    |
| Share       | `share_plus`         | ^7.2.0            | Social sharing    |
| TTS         | `flutter_tts`        | ^3.8.5            | Text-to-Speech    |
| Permissions | `permission_handler` | ^11.3.0           | OS permissions    |

### Rules

1. **Check compatibility before upgrading** - especially `flutter_quill` which has breaking API changes.
2. **Use version ranges** with caret (^) for minor updates.
3. **Document new dependencies** in pubspec.yaml with comments.

---

## 🧪 Testing

### Structure

```
test/
├── text_utilities_test.dart   # Unit tests for utilities
├── widget_test.dart           # Widget tests
└── [feature]_test.dart        # Feature-specific tests
```

### Naming Convention

```dart
test('[methodName] [expected behavior]', () {
  expect(TextUtilities.toUpperCase('hello'), 'HELLO');
});
```

### Rules

1. **Group tests by functionality** using `group()`.
2. **Test pure functions first** (easiest to test).
3. **Run `flutter test` before committing.**

---

## 📝 Code Style

### Imports Order

```dart
// 1. Dart SDK
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Local imports (relative)
import '../providers/editor_provider.dart';
```

### Naming Conventions

| Element   | Convention           | Example                    |
| --------- | -------------------- | -------------------------- |
| Files     | snake_case           | `editor_screen.dart`       |
| Classes   | PascalCase           | `EditorScreen`             |
| Functions | camelCase            | `handleSave()`             |
| Constants | camelCase            | `primaryColor`             |
| Providers | camelCase + Provider | `editorControllerProvider` |

### Documentation

```dart
/// Brief description of what this does.
///
/// [parameter] - Optional parameter description.
/// Returns: What it returns.
void myFunction(String parameter) { ... }
```

---

## 🔧 Platform Configuration

### Android

- **minSdk**: 21
- **targetSdk**: Latest (flutter.targetSdkVersion)
- **Desugaring**: Enabled for Java 8 APIs
- **Permissions**: Storage, TTS in `AndroidManifest.xml`

### iOS

- **Minimum iOS**: 12.0
- **Permissions**: Add usage descriptions to `Info.plist`

### Windows

- **Developer Mode**: Required for symlinks (plugin support)

---

## 🚀 Build Commands

```bash
# Development
flutter run -d windows
flutter run -d chrome

# Analysis
flutter analyze
flutter test

# Release builds
flutter build windows --release
flutter build apk --release

# Generate icons
dart run flutter_launcher_icons
```

---

## ⚠️ Common Pitfalls

1. **flutter_quill API changes**: v11 uses `QuillEditor.basic()` and `QuillSimpleToolbar`.
2. **TtsService is singleton**: Use `TtsService.instance`, not `TtsService()`.
3. **FileService uses static methods**: Call `FileService.loadDocument()`, not instance methods.
4. **Provider disposal**: StateNotifier should call `state.dispose()` in its `dispose()`.

---

## 📋 Commit Convention

```
<phase>: <description>

Examples:
P0: Fix Gradle cache issue
P1: Add export menu with PDF support
P2: Add unit tests for TextUtilities
refactor: Extract toolbar to separate widget
fix: Handle null file path in save dialog
```
