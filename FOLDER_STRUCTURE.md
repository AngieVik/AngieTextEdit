# Flutter Rich Text Editor - Folder Structure Preview

```
d:\Proyectos\AngieTextEdit\
├── pubspec.yaml                    ✅ Created
├── lib/
│   ├── main.dart                   # App entry point with ProviderScope
│   ├── app.dart                    # MaterialApp configuration
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart     # Color palette
│   │   ├── theme/
│   │   │   └── app_theme.dart      # ThemeData configuration
│   │   └── utils/
│   │       └── text_utilities.dart # 14 pure Dart text functions
│   │
│   ├── features/
│   │   ├── editor/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── editor_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── custom_toolbar.dart
│   │   │   │       └── clipboard_handler.dart
│   │   │   └── providers/
│   │   │       ├── editor_provider.dart
│   │   │       └── auto_save_provider.dart
│   │   │
│   │   ├── utilities/
│   │   │   ├── presentation/
│   │   │   │   └── widgets/
│   │   │   │       └── utils_sidebar.dart
│   │   │   └── providers/
│   │   │       └── text_utils_provider.dart
│   │   │
│   │   └── export/
│   │       ├── services/
│   │       │   ├── pdf_export_service.dart
│   │       │   ├── html_export_service.dart
│   │       │   └── file_service.dart
│   │       └── providers/
│   │           └── export_provider.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   └── responsive_layout.dart
│       └── services/
│           ├── permission_service.dart
│           ├── tts_service.dart
│           └── storage_service.dart
│
├── android/
│   └── app/src/main/AndroidManifest.xml  # Storage permissions
│
├── ios/
│   └── Runner/Info.plist                  # Document/TTS permissions
│
├── windows/                               # Desktop support
├── macos/                                 # Desktop support
│
└── test/
    ├── text_utilities_test.dart
    ├── editor_provider_test.dart
    └── widgets/
        ├── custom_toolbar_test.dart
        └── utils_sidebar_test.dart
```

## Summary

| Category       | Count                         |
| -------------- | ----------------------------- |
| **Dart Files** | 18                            |
| **Features**   | 3 (Editor, Utilities, Export) |
| **Providers**  | 5                             |
| **Services**   | 6                             |
| **Test Files** | 4+                            |
