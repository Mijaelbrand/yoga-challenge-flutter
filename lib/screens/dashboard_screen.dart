import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/yoga_message.dart';
// Removed HybridVideoScreen - daily videos open in external browser like Android

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserMessages();
  }

  Future<void> _loadUserMessages() async {
    // Update day progression based on elapsed time (not completions)
    final appState = Provider.of<AppState>(context, listen: false);
    appState.updateDayProgressBasedOnTime();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Consumer<AppState>(
          builder: (context, appState, child) {
            
            try {
          
          // Safety check - if no messages, show loading or generate them
          if (appState.userScheduledMessages.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await appState.generateUserMessages();
              } catch (e) {
                appState.setLastError('Message generation failed: $e');
              }
            });
            
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Preparando tu desafío...'),
                ],
              ),
            );
          }
          
          try {
            final todaysMessage = appState.getTodaysMessage();
            final nextMessage = appState.getNextMessage();
            final progressPercentage = appState.getProgressPercentage();
            return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Section
                _buildProgressCard(context, appState, progressPercentage),
                
                const SizedBox(height: 16),
                
                // Streak Section
                _buildStreakCard(context, appState),
                
                const SizedBox(height: 16),
                
                // Today's Message Section
                _buildTodaysMessageCard(context, appState, todaysMessage),
                
                const SizedBox(height: 16),
                
                // Next Session
                if (nextMessage != null) _buildNextSessionCard(context, nextMessage),
                
                const SizedBox(height: 16),
                
                // Access Days
                _buildAccessDaysCard(context, appState),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                _buildActionButtons(context, appState, todaysMessage),
              ],
            ),
          );
          
          } catch (e) {
            appState.setLastError('Dashboard content failed: $e');
            
            // Return error screen instead of crashing
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error building dashboard', style: TextStyle(fontSize: 18, color: Colors.red)),
                  SizedBox(height: 8),
                  Text('$e', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to rebuild
                      if (mounted) setState(() {});
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          } catch (consumerError) {
            
            // Return basic error screen
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Consumer Error', style: TextStyle(fontSize: 18, color: Colors.red)),
                  Text('$consumerError', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }
        },
        ),
      ),
    );
    
    } catch (buildError) {
      
      // Final fallback error screen
      return Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 100, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'CRITICAL ERROR', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)
                ),
                SizedBox(height: 16),
                Text(
                  'Dashboard failed to build completely', 
                  style: TextStyle(fontSize: 16, color: Colors.red[800]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$buildError',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // Try to go back or restart
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Go Back', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildProgressCard(BuildContext context, AppState appState, int progressPercentage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Día ${appState.practiceCompletions.length + 1} de 31',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '$progressPercentage% completado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, AppState appState) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.accentLight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 ${appState.currentStreak} day streak',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Racha más larga: ${appState.longestStreak} días',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Practice completion checkbox
            Checkbox(
              value: appState.isPracticeCompletedForDate(
                DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
              onChanged: (value) {
                if (value == true) {
                  appState.addPracticeCompletion(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  );
                  _updateStreak(appState);
                } else {
                  appState.removePracticeCompletion(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  );
                }
              },
              activeColor: AppColors.primary,
            ),
            
            const SizedBox(width: 8),
            
            Text(
              'Completada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMessageCard(BuildContext context, AppState appState, YogaMessage? todaysMessage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.todayMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              todaysMessage?.fullMessage ?? AppStrings.noPracticeToday,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            
            if (todaysMessage != null) ...[
              const SizedBox(height: 16),
              
              // Video access button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openVideo(todaysMessage),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(todaysMessage.videoButtonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Affirmation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.messageBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                todaysMessage?.notificationText ?? '🌿 Eres más fuerte de lo que crees',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSessionCard(BuildContext context, YogaMessage nextMessage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.primary,
              size: 24,
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próxima sesión',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  Text(
                    DateFormat("EEEE 'a las' HH:mm", 'es').format(nextMessage.scheduledDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDaysCard(BuildContext context, AppState appState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: appState.remainingAccessDays <= 5 ? AppColors.error : AppColors.textSecondary,
              size: 24,
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                'Acceso: ${appState.remainingAccessDays} días restantes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appState.remainingAccessDays <= 5 ? AppColors.error : AppColors.textSecondary,
                  fontWeight: appState.remainingAccessDays <= 5 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppState appState, YogaMessage? todaysMessage) {
    return Column(
      children: [
        // WhatsApp Contact Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _openWhatsApp(),
            icon: const Icon(Icons.message),
            label: const Text(AppStrings.whatsappContact),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.whatsappGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 4,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Instagram button removed per user request
      ],
    );
  }

  void _updateStreak(AppState appState) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);
    
    final newStreak = appState.isPracticeCompletedForDate(yesterdayStr)
        ? appState.currentStreak + 1
        : 1;
    
    appState.setCurrentStreak(newStreak);
  }

  // Opens hybrid video URL - matches Android MainActivity.openHybridVideoUrl exactly  
  void _openVideo(YogaMessage message) {
    print('🎬 DEBUG: Opening video - URL: ${message.videoUrl}');
    print('🎬 DEBUG: Video title: ${message.notificationTitle}');
    
    // Show visible feedback that button was clicked
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎬 DEBUG: Video button clicked - ${message.videoUrl}'),
        duration: Duration(seconds: 2),
      ),
    );
    
    if (message.videoUrl.startsWith('http')) {
      // Direct URL (like WhatsApp link) - launch externally
      print('🎬 DEBUG: Direct URL detected, launching externally');
      launchUrl(Uri.parse(message.videoUrl));
    } else {
      // Video ID - use hybrid video system just like Android
      print('🎬 DEBUG: Video ID detected, using hybrid system');
      _openHybridVideoUrl(message.videoUrl, message.notificationTitle);
    }
  }
  
  // Matches Android MainActivity.openHybridVideoUrl exactly
  void _openHybridVideoUrl(String videoId, String title) async {
    print('🎬 DEBUG: _openHybridVideoUrl called with videoId: $videoId, title: $title');
    
    final appState = Provider.of<AppState>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = appState.userPhone;
    
    print('🎬 DEBUG: User phone number: $phoneNumber');
    
    if (phoneNumber == null || phoneNumber.isEmpty) {
      print('🎬 DEBUG: ❌ No phone number found');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No se encontró el número de teléfono'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    try {
      print('🎬 v1.1.33 COMPLETADA FIX: Requesting video token from server...');
      print('🎬 v1.1.33 COMPLETADA FIX: Using iOS-specific endpoint (ios-get-video-token.php)');
      // Get video token from server - uses iOS-specific endpoint
      final token = await authProvider.getVideoToken(phoneNumber);
      print('🎬 v1.1.33 COMPLETADA FIX: Token result: $token');
      print('🎬 v1.1.33 COMPLETADA FIX: Token format: ${token?.startsWith('token_') == true ? 'CORRECT ✅' : 'INCORRECT ❌ - should start with token_ not ios_token_'}');
      
      if (token != null && token.isNotEmpty) {
        print('🎬 DEBUG: ✅ Token received, building hybrid URL...');
        
        // Show visible success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Token received: ${token.substring(0, 8)}... Launching video...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Build hybrid URL exactly like Android
        final hybridUrl = authProvider.buildHybridVideoUrl(videoId, token, phoneNumber);
        print('🎬 DEBUG: Built hybrid URL: $hybridUrl');
        
        // Launch in external browser - matches Android Intent.ACTION_VIEW exactly
        print('🎬 DEBUG: Launching URL in external browser...');
        await launchUrl(Uri.parse(hybridUrl), mode: LaunchMode.externalApplication);
        print('🎬 DEBUG: ✅ URL launched successfully');
      } else {
        print('🎬 DEBUG: ❌ Token is null or empty, showing access error');
        
        // Show visible error feedback with API details for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Token failed. Phone: $phoneNumber\nAPI: get-video-token.php'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _openHybridVideoUrl(videoId, title),
            ),
          ),
        );
      }
    } catch (e) {
      print('🎬 DEBUG: ❌ Exception in _openHybridVideoUrl: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión. Intenta nuevamente.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openWhatsApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = authProvider.generateWhatsAppSupportLink();
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // _openInstagram method removed - Instagram button removed per user request
  
}





