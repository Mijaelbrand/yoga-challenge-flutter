import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F52BD);  // Indigo - matching Android
  static const Color primaryDark = Color(0xFF3D4199);  // Matching Android primary_dark
  static const Color primaryLight = Color(0xFF7376D5);  // Matching Android primary_light
  static const Color accent = Color(0xFF438F62);  // Green - matching Android
  static const Color background = Color(0xFFFFFFFF);  // Pure white - matching Android
  static const Color surface = Color(0xFFFAFAFA);  // Matching Android surface
  static const Color textPrimary = Color(0xFF4A4A4A);  // Grey - matching Android
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFF751717);  // Red - matching Android
  static const Color success = Color(0xFF438F62);  // Green - matching Android
  static const Color warning = Color(0xFFF59E0B);  // Matching Android
  static const Color info = Color(0xFF246885);  // Teal - matching Android
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color messageBackground = Color(0xFFE9F4FF);  // Matching Android
  static const Color accentLight = Color(0xFFE8F5E9);  // Matching Android accent_light
}

class AppStrings {
  // Welcome Screen
  static const String welcomeTitle = "Desafío Akila";
  static const String welcomeSubtitle = "Una práctica transformativa, al alcance de tu mano";
  static const String startButton = "Comienza Tu Viaje";
  
  // Phone Entry
  static const String phoneEntryTitle = "Ingresa Tu Número de Teléfono";
  static const String phoneEntrySubtitle = "Lo usaremos para enviarte recordatorios y actualizaciones";
  static const String phoneHint = "Número de Teléfono";
  static const String continueButton = "Continuar";
  static const String privacyPolicy = "Ver Política de Privacidad";
  static const String errorPhoneInvalid = "Por favor ingresa un número válido";
  
  // Intro Video
  static const String introVideoTitle = "Introducción:";
  static const String introVideoSubtitle = "Si todavía no viste este video introductorio, dura un minuto y es importante:";
  static const String finishedButton = "Continuar";
  
  // Welcome Journey
  static const String journeyTitle = "Bienvenid@ a Tu Viaje";
  static const String journeySubtitle = "¡Yey! 🎉\n\nEstás a punto de iniciar un camino que podría cambiar tu vida para siempre";
  static const String journeyContinue = "¡VAMOS ADELANTE!";
  
  // Day Selection
  static const String daySelectionTitle = "Elige Tus Días de Práctica";
  static const String daySelectionSubtitle = "Selecciona al menos 2 días por semana, y elige a qué hora quieres hacer tu práctica";
  static const String confirmButton = "Confirmar Horario";
  static const String selectedDays = "Seleccionados: {count} días";
  static const String errorMinDays = "Por favor selecciona al menos 2 días por semana";
  static const String selectTime = "Seleccionar hora";
  
  // Dashboard
  static const String dashboardTitle = "Mi Desafío";
  static const String dayProgress = "Día {day} de 31";
  static const String nextSession = "Próxima sesión: {session}";
  static const String streakText = "🔥 Racha de {streak} días";
  static const String practiceCompleted = "Completado";
  static const String todayMessage = "Mensaje de hoy";
  static const String noPracticeToday = "No hay práctica programada para hoy";
  static const String accessDays = "Acceso: {days} días restantes";
  static const String whatsappContact = "Contacto WhatsApp";
  
  // Challenge Complete
  static const String challengeCompleteTitle = "¡Felicitaciones!";
  static const String challengeCompleteSubtitle = "Has completado el Desafío Akila de 30 Días";
  static const String finalStreak = "Racha más larga: {streak} días 🔥";
  static const String totalPractices = "Total de prácticas: {count} sesiones";
  static const String joinCommunity = "Síguenos en Instagram";
  static const String monthlyClassNotice = "Mantente conectado para clases mensuales gratuitas";
  
  // Errors
  static const String errorConnection = "Error de conexión";
  static const String errorUnexpected = "Ocurrió un error inesperado";
  static const String accessExpired = "Tu acceso ha expirado después de 40 días";
  static const String registrationRequired = "Teléfono no registrado. Por favor regístrate primero.";
  
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
  static const String checkPhoneUrl = "https://akilainstitute.com/api/yoga/check-phone.php";
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
  // Only include assets that actually exist
  static const String messagesData = "assets/data/yoga_messages.json";
  
  // Placeholder assets (commented out until we add them)
  // static const String logo = "assets/images/logo.png";
  // static const String yogaIcon = "assets/icons/yoga.svg";
  // static const String trophyIcon = "assets/icons/trophy.svg";
  // static const String whatsappIcon = "assets/icons/whatsapp.svg";
  // static const String playIcon = "assets/icons/play.svg";
}
