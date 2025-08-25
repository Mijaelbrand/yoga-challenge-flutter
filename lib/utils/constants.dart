import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color messageBackground = Color(0xFFF8F9FA);
  static const Color accentLight = Color(0xFFFFF3E0);
}

class AppStrings {
  // Welcome Screen
  static const String welcomeTitle = "¡Bienvenido al Desafío de Yoga!";
  static const String welcomeSubtitle = "Transforma tu vida con 31 días de práctica consciente";
  static const String startButton = "Comenzar";
  
  // Phone Entry
  static const String phoneEntryTitle = "Ingresa tu número de teléfono";
  static const String phoneEntrySubtitle = "Para verificar tu registro y acceder al desafío";
  static const String phoneHint = "Número de teléfono";
  static const String continueButton = "Continuar";
  static const String privacyPolicy = "Política de Privacidad";
  static const String errorPhoneInvalid = "Por favor ingresa un número válido";
  
  // Intro Video
  static const String introVideoTitle = "Video de Introducción";
  static const String introVideoSubtitle = "Mira este video para comenzar tu viaje";
  static const String finishedButton = "Terminé de ver";
  
  // Welcome Journey
  static const String journeyTitle = "¡Bienvenido a tu viaje!";
  static const String journeySubtitle = "Estás a un paso de transformar tu vida";
  static const String journeyContinue = "Continuar";
  
  // Day Selection
  static const String daySelectionTitle = "Selecciona tus días de práctica";
  static const String daySelectionSubtitle = "Elige los días y horarios que mejor te funcionen";
  static const String confirmButton = "Confirmar";
  static const String selectedDays = "Seleccionados: {count} días";
  static const String errorMinDays = "Selecciona al menos 2 días";
  static const String selectTime = "Seleccionar hora";
  
  // Dashboard
  static const String dashboardTitle = "Mi Desafío";
  static const String dayProgress = "Día {day} de 31";
  static const String nextSession = "Próxima sesión: {session}";
  static const String streakText = "🔥 {streak} day streak";
  static const String practiceCompleted = "Práctica completada";
  static const String todayMessage = "MENSAJE DE HOY";
  static const String noPracticeToday = "No hay práctica programada para hoy";
  static const String accessDays = "Acceso: {days} días restantes";
  static const String whatsappContact = "Contacto WhatsApp";
  
  // Challenge Complete
  static const String challengeCompleteTitle = "¡Desafío Completado!";
  static const String finalStreak = "Racha más larga: {streak} días 🔥";
  static const String totalPractices = "Total de prácticas: {count} sesiones";
  static const String joinCommunity = "Unirse a la Comunidad";
  
  // Errors
  static const String errorConnection = "Error de conexión";
  static const String errorUnexpected = "Ocurrió un error inesperado";
  static const String accessExpired = "Tu acceso ha expirado. Contacta soporte para renovar.";
  static const String registrationRequired = "Tu número no está registrado. Regístrate primero.";
  
  // Days of the week
  static const List<String> daysOfWeek = [
    "Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"
  ];
  
  static const List<String> daysShort = [
    "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"
  ];
}

class AppConfig {
  static const String apiBaseUrl = "https://akilainstitute.com/api/yoga";
  static const String manyChatWebhookUrl = "https://akilainstitute.com/api/yoga/manychat-webhook.php";
  static const String checkPhoneUrl = "https://akilainstitute.com/api/yoga/check-phone-v2.php";
  static const String videoBaseUrl = "https://akilainstitute.com/api/yoga/video.php";
  static const String whatsappNumber = "+13202897388";
  static const String instagramUrl = "https://www.instagram.com/akilainstitute/";
  static const String privacyPolicyUrl = "https://akilainstitute.com/politica-de-privacidad/";
  
  // Challenge settings
  static const int challengeDurationDays = 31;
  static const int accessLimitDays = 40;
  static const int minPracticeDays = 2;
  static const int maxPracticeDays = 7;
  
  // Video settings
  static const String introVideoId = "1112594299";
  static const String vimeoBaseUrl = "https://player.vimeo.com/video/";
}

class AppAssets {
  static const String logo = "assets/images/logo.png";
  static const String yogaIcon = "assets/icons/yoga.svg";
  static const String trophyIcon = "assets/icons/trophy.svg";
  static const String whatsappIcon = "assets/icons/whatsapp.svg";
  static const String playIcon = "assets/icons/play.svg";
  static const String messagesData = "assets/data/yoga_messages.json";
}
