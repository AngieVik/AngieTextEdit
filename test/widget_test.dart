// Basic widget test for AngieTextEdit
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:angie_text_edit/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AngieTextEditApp(),
      ),
    );

    // Verify that the app title is shown
    expect(find.text('Angie Text Edit'), findsOneWidget);
  });
}
