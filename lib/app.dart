import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/editor/presentation/screens/editor_screen.dart';

/// Main application widget for AngieTextEdit
class AngieTextEditApp extends StatelessWidget {
  const AngieTextEditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angie Text Edit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const EditorScreen(),
    );
  }
}
