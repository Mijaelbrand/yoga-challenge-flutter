import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import 'welcome_screen.dart';
import 'phone_entry_screen.dart';
import 'intro_video_screen.dart';
import 'welcome_journey_screen.dart';
import 'day_selection_screen.dart';
import 'dashboard_screen.dart';
import 'challenge_complete_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.checkAppState();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Navigate to appropriate screen based on app state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appState.currentScreen != AppScreen.splash) {
              _navigateToScreen(appState.currentScreen);
            }
          });
          
          return Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // App Title
                        Text(
                          'Yoga Challenge',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          'Transforma tu vida con práctica consciente',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Loading indicator
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Text(
                          'Cargando...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToScreen(AppScreen screen) {
    Widget targetScreen;
    
    switch (screen) {
      case AppScreen.welcome:
        targetScreen = const WelcomeScreen();
        break;
      case AppScreen.phoneEntry:
        targetScreen = const PhoneEntryScreen();
        break;
      case AppScreen.introVideo:
        targetScreen = const IntroVideoScreen();
        break;
      case AppScreen.welcomeJourney:
        targetScreen = const WelcomeJourneyScreen();
        break;
      case AppScreen.daySelection:
        targetScreen = const DaySelectionScreen();
        break;
      case AppScreen.dashboard:
        targetScreen = const DashboardScreen();
        break;
      case AppScreen.challengeComplete:
        targetScreen = const ChallengeCompleteScreen();
        break;
      default:
        targetScreen = const WelcomeScreen();
    }
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}




