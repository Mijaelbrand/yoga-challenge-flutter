import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'services/firebase_analytics_service_stub.dart';  // Analytics stub for simulator
import 'services/fcm_service.dart';  // Keep FCM for notifications
import 'services/secure_storage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('[Main] ✅ Firebase initialized');
    
    // Set up background message handler (must be at top level)
    FirebaseMessaging.onBackgroundMessage(FCMService.handleBackgroundMessage);
    
    // Initialize Firebase services
    await FirebaseAnalyticsService.initialize();  // Analytics stub for simulator
    await FCMService.initialize();  // Keep FCM for notifications
    
    // Initialize secure storage
    await SecureStorage.instance.initialize();
    
    // Initialize date formatting for locales
    await initializeDateFormatting('es', null); // Spanish
    await initializeDateFormatting('en', null); // English fallback
    
    // Initialize notifications
    await NotificationProvider.initialize();
    
    // Request notification permissions
    await Permission.notification.request();
    
    // Log app launch (stub for simulator build)
    await FirebaseAnalyticsService.logAppOpen();
    
    print('[Main] ✅ All services initialized successfully');
  } catch (e) {
    print('[Main] ❌ Error initializing services: $e');
    // Continue app launch even if some services fail
  }
  
  runApp(const YogaChallengeApp());
}

class YogaChallengeApp extends StatelessWidget {
  const YogaChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Yoga Challenge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // cardTheme removed for Flutter version compatibility
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}





