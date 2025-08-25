import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/yoga_message.dart';
import 'hybrid_video_screen.dart';

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
    // TODO: Load user's scheduled messages from API or local storage
    // For now, we'll use placeholder data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Show settings dialog
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
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
        },
      ),
    );
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
              'Día ${appState.userScheduledMessages.isNotEmpty ? (appState.userScheduledMessages.first.messageNumber) : 1} de 31',
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
        
        // Community Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _openInstagram(),
            icon: const Icon(Icons.people),
            label: Text(AppStrings.joinCommunity),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
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
    if (message.videoUrl.startsWith('http')) {
      // Direct URL (like WhatsApp link) - launch externally
      launchUrl(Uri.parse(message.videoUrl));
    } else {
      // Video ID - use hybrid video system just like Android
      _openHybridVideoUrl(message.videoUrl, message.notificationTitle);
    }
  }
  
  // Matches Android MainActivity.openHybridVideoUrl exactly
  void _openHybridVideoUrl(String videoId, String title) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = appState.userPhone;
    
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No se encontró el número de teléfono'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    try {
      // Get video token from server - matches Android MessageScheduler.buildHybridVideoUrl
      final token = await authProvider.getVideoToken(phoneNumber);
      
      if (token != null && token.isNotEmpty) {
        debugPrint('Opening hybrid URL for video: $videoId');
        
        // Navigate to hybrid video screen with WebView - matches Android VideoPlayerActivity
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HybridVideoScreen(
              videoId: videoId,
              title: title,
              phoneNumber: phoneNumber,
              token: token,
            ),
          ),
        );
      } else {
        // Fallback: show access error - matches Android
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder al video. Verifica tu registro.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening hybrid video URL: $e');
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

  void _openInstagram() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = authProvider.getInstagramCommunityLink();
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}


