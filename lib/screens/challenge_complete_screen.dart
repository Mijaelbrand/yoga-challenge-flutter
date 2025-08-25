import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class ChallengeCompleteScreen extends StatelessWidget {
  const ChallengeCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Trophy Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: AppColors.accent,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                AppStrings.challengeCompleteTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                '¡Felicitaciones por completar tu desafío de yoga!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Stats Cards
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return Column(
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.local_fire_department,
                        title: AppStrings.finalStreak.replaceAll('{streak}', appState.longestStreak.toString()),
                        subtitle: 'Tu racha más larga de práctica consecutiva',
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildStatCard(
                        context,
                        icon: Icons.fitness_center,
                        title: AppStrings.totalPractices.replaceAll('{count}', appState.practiceCompletions.length.toString()),
                        subtitle: 'Total de sesiones completadas',
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Motivational Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.messageBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Has dado un paso increíble hacia tu bienestar. ¡Continúa tu práctica y mantén viva la llama del yoga en tu vida!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Action Buttons
              Column(
                children: [
                  // Join Community Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInstagram(context),
                      icon: const Icon(Icons.people),
                      label: const Text(AppStrings.joinCommunity),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // WhatsApp Support Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _openWhatsApp(context),
                      icon: const Icon(Icons.message),
                      label: const Text('Contactar Soporte'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.whatsappGreen,
                        side: BorderSide(color: AppColors.whatsappGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Restart Challenge Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => _restartChallenge(context),
                      child: Text(
                        'Reiniciar Desafío',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Footer
              Text(
                'Gracias por ser parte de nuestra comunidad de yoga',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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

  void _openInstagram(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = authProvider.getInstagramCommunityLink();
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openWhatsApp(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = authProvider.generateWhatsAppSupportLink();
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _restartChallenge(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.resetAppState();
  }
}

