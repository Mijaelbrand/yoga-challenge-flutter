import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yoga_challenge_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Yoga Challenge App Integration Tests', () {
    testWidgets('Complete user flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await Future.delayed(Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on welcome screen
      expect(find.text('Yoga Challenge'), findsOneWidget);
      expect(find.text('Transforma tu vida con yoga'), findsOneWidget);

      // Tap start button
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Should be on phone entry screen
      expect(find.text('Ingresa tu número de teléfono'), findsOneWidget);

      // Enter phone number
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField, '+1234567890');
      await tester.pump();

      // Tap verify button
      await tester.tap(find.text('Verificar'));
      await tester.pumpAndSettle();

      // Should show loading or result
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('App state persistence test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await Future.delayed(Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate through app
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Enter phone number
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField, '+1234567890');
      await tester.pump();

      // Tap verify
      await tester.tap(find.text('Verificar'));
      await tester.pumpAndSettle();

      // Restart app to test persistence
      app.main();
      await tester.pumpAndSettle();

      // Should remember previous state
      // (This would depend on your app's state management)
    });

    testWidgets('Error handling test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await Future.delayed(Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to phone entry
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Enter invalid phone number
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField, 'invalid');
      await tester.pump();

      // Tap verify
      await tester.tap(find.text('Verificar'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Por favor ingresa un número válido'), findsOneWidget);
    });

    testWidgets('Navigation flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await Future.delayed(Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Test navigation through all screens
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Should be on phone entry
      expect(find.text('Ingresa tu número de teléfono'), findsOneWidget);

      // Test back navigation (if implemented)
      // await tester.pageBack();
      // await tester.pumpAndSettle();
      // expect(find.text('Yoga Challenge'), findsOneWidget);
    });
  });
}
