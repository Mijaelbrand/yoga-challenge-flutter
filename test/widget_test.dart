import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yoga_challenge_flutter/main.dart';
import 'package:yoga_challenge_flutter/providers/app_state.dart';
import 'package:yoga_challenge_flutter/screens/welcome_screen.dart';
import 'package:yoga_challenge_flutter/screens/dashboard_screen.dart';
import 'package:yoga_challenge_flutter/screens/phone_entry_screen.dart';

void main() {
  group('Yoga Challenge App Widget Tests', () {
    testWidgets('App should start with splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(YogaChallengeApp());
      
      // Should show splash screen initially
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Welcome screen should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
          ],
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      // Check for welcome screen elements
      expect(find.text('Yoga Challenge'), findsOneWidget);
      expect(find.text('Transforma tu vida con yoga'), findsOneWidget);
      expect(find.text('Comenzar'), findsOneWidget);
    });

    testWidgets('Phone entry screen should validate input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
          ],
          child: MaterialApp(
            home: PhoneEntryScreen(),
          ),
        ),
      );

      // Find phone input field
      final phoneField = find.byType(TextFormField);
      expect(phoneField, findsOneWidget);

      // Enter invalid phone number
      await tester.enterText(phoneField, '123');
      await tester.pump();

      // Find verify button
      final verifyButton = find.text('Verificar');
      expect(verifyButton, findsOneWidget);

      // Tap verify button
      await tester.tap(verifyButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Por favor ingresa un número válido'), findsOneWidget);
    });

    testWidgets('Dashboard should show progress elements', (WidgetTester tester) async {
      final appState = AppState();
      appState.setPhoneNumber('+1234567890');
      appState.setChallengeStartDate(DateTime.now());
      appState.setIntroCompleted(true);
      appState.setCurrentScreen(AppScreen.dashboard);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appState),
          ],
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Check for dashboard elements
      expect(find.text('Día 1'), findsOneWidget);
      expect(find.text('Próxima sesión'), findsOneWidget);
      expect(find.text('Días restantes'), findsOneWidget);
    });

    testWidgets('Navigation between screens should work', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appState),
          ],
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      // Tap start button
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Should navigate to phone entry screen
      expect(find.byType(PhoneEntryScreen), findsOneWidget);
    });
  });
}
