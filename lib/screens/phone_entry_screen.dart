import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'intro_video_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.verificationTitle),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  AppStrings.phoneEntryTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Version indicator for debugging
                Text(
                  'DEBUG: App v1.1.3 - Build #31',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  AppStrings.phoneEntrySubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Phone Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s\(\)]')),
                  ],
                  decoration: InputDecoration(
                    labelText: AppStrings.phoneHint,
                    prefixIcon: const Icon(Icons.phone),
                    hintText: 'Ej: +1234567890',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu número de teléfono';
                    }
                    // Match Android validation: just check total length >= 10
                    final trimmed = value.trim();
                    if (trimmed.length < 10) {
                      return AppStrings.errorPhoneInvalid;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppStrings.continueButton,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Privacy Policy Link
                Center(
                  child: GestureDetector(
                    onTap: _openPrivacyPolicy,
                    child: Text(
                      AppStrings.privacyPolicy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.messageBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tu número se verifica con nuestro sistema para asegurar que tienes acceso al desafío.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);
      
      final result = await authProvider.verifyPhone(_phoneController.text.trim());
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (result.error != null) {
          _showErrorDialog('Error de conexión', 'No se pudo verificar el teléfono. Inténtalo más tarde.');
        } else if (!result.isRegistered) {
          _showRegistrationDialog();
        } else if (result.isAccessExpired) {
          _showAccessExpiredDialog();
        } else {
          // Success - save phone and continue
          appState.setUserPhone(_phoneController.text.trim());
          appState.setRemainingAccessDays(result.remainingDays);
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const IntroVideoScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error', 'Ocurrió un error inesperado: $e');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.registrationRequiredTitle),
        content: const Text(
          'Tu número de teléfono no está registrado. Pero no te preocupes, hacerlo toma unos segundos solamente: aprieta en registrarse y te llevará a una conversación en Instagram, donde podrás registrarlo en 15 segundos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openRegistration();
            },
            child: Text(AppStrings.register),
          ),
        ],
      ),
    );
  }

  void _showAccessExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.accessExpiredTitle),
        content: const Text(AppStrings.accessExpired),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openWhatsAppSupport();
            },
            child: Text(AppStrings.contactSupport),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() async {
    const url = AppConfig.privacyPolicyUrl;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = authProvider.generateManyChatSignupLink();
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openWhatsAppSupport() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = authProvider.generateWhatsAppSupportLink();
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}


