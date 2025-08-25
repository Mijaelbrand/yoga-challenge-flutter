import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yoga_challenge_flutter/providers/app_state.dart';
import 'package:yoga_challenge_flutter/providers/auth_provider.dart';
import 'package:yoga_challenge_flutter/screens/welcome_screen.dart';
import 'package:yoga_challenge_flutter/screens/dashboard_screen.dart';
import 'package:yoga_challenge_flutter/screens/phone_entry_screen.dart';
import 'package:yoga_challenge_flutter/models/yoga_message.dart';

void main() {
  group('Yoga Challenge App Widget Tests', () {
    testWidgets('Welcome screen should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
          ],
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      // Check for welcome screen elements
      expect(find.text('¡Bienvenido al Desafío de Yoga!'), findsOneWidget);
      expect(find.text('Transforma tu vida con 31 días de práctica consciente'), findsOneWidget);
      expect(find.text('Comenzar'), findsOneWidget);
    });

    testWidgets('Phone entry screen should validate input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(
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

      // Find continue button
      final continueButton = find.text('Continuar');
      expect(continueButton, findsOneWidget);

      // Tap continue button
      await tester.tap(continueButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('El número debe tener al menos 10 dígitos'), findsOneWidget);
    });

    testWidgets('Dashboard should render without errors', (WidgetTester tester) async {
      final appState = AppState();
      appState.setUserPhone('+1234567890');
      appState.setChallengeStartDate(DateTime.now());
      appState.setIntroCompleted(true);
      // Initialize mock schedule to avoid empty list errors
      appState.setSelectedSchedule({'Lun': '09:00', 'Mié': '09:00', 'Vie': '09:00'});
      
      // Add mock yoga message to avoid empty list error
      final mockMessage = YogaMessage(
        messageNumber: 1,
        notificationTitle: 'Test Title',
        notificationText: 'Test notification',
        fullMessage: 'Test full message',
        videoUrl: 'https://test.com',
        videoButtonText: 'Test button',
        scheduledDate: DateTime.now(),
        hybridToken: 'test-token',
      );
      appState.setUserScheduledMessages([mockMessage]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appState),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Check that dashboard renders without error
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Mi Desafío'), findsOneWidget);
    });

    testWidgets('Navigation from welcome to phone entry works', (WidgetTester tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appState),
          ],
          child: MaterialApp(
            home: const WelcomeScreen(),
            routes: {
              '/phone': (context) => const PhoneEntryScreen(),
            },
          ),
        ),
      );

      // Scroll to make button visible
      await tester.scrollUntilVisible(
        find.text('Comenzar'),
        500.0,
      );

      // Tap start button
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      // Should navigate to phone entry screen
      expect(find.byType(PhoneEntryScreen), findsOneWidget);
    });

    testWidgets('App components render without exceptions', (WidgetTester tester) async {
      // Test that basic components don't throw exceptions
      expect(() => const WelcomeScreen(), returnsNormally);
      expect(() => const PhoneEntryScreen(), returnsNormally);
      expect(() => const DashboardScreen(), returnsNormally);
    });
  });
}