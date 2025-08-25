import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import '../models/yoga_message.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  PhoneVerificationResult? _verificationResult;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PhoneVerificationResult? get verificationResult => _verificationResult;
  
  // Verify phone number with ManyChat
  Future<PhoneVerificationResult> verifyPhone(String phone) async {
    setLoading(true);
    setError(null);
    
    try {
      // Match Android: just trim and send as-is, only encoding the + sign
      final trimmedPhone = phone.trim();
      
      // Use GET request to match Android implementation
      // Only replace + with %2B, keep everything else as-is (spaces, dashes, parentheses)
      final encodedPhone = trimmedPhone.replaceAll('+', '%2B');
      
      final url = '${AppConfig.checkPhoneUrl}?phone=$encodedPhone';
      debugPrint('=== NETWORK DEBUG START ===');
      debugPrint('📞 Original phone: "$phone"');
      debugPrint('📞 Trimmed phone: "$trimmedPhone"');
      debugPrint('📞 Encoded phone: "$encodedPhone"');
      debugPrint('🌐 Full API URL: $url');
      debugPrint('🌐 Base URL: ${AppConfig.checkPhoneUrl}');
      
      // Use Dio HTTP client for better iOS compatibility
      final dio = Dio();
      
      // Add detailed logging interceptor
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('🔍 DIO: $obj'),
      ));
      
      // Configure timeouts and headers
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      dio.options.sendTimeout = const Duration(seconds: 30);
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'YogaChallenge/1.0.1 (iOS)',
      };
      
      debugPrint('⚙️ Dio configuration:');
      debugPrint('   - Connect timeout: ${dio.options.connectTimeout}');
      debugPrint('   - Receive timeout: ${dio.options.receiveTimeout}');
      debugPrint('   - Headers: ${dio.options.headers}');
      
      debugPrint('🚀 Making HTTP GET request...');
      final stopwatch = Stopwatch()..start();
      
      final response = await dio.get(url);
      
      stopwatch.stop();
      debugPrint('⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📱 Response status: ${response.statusCode}');
      debugPrint('📱 Response headers: ${response.headers}');
      debugPrint('📱 Response data type: ${response.data.runtimeType}');
      debugPrint('📱 Response data: ${response.data}');
      debugPrint('=== NETWORK DEBUG SUCCESS ===');
      
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        _verificationResult = PhoneVerificationResult.fromJson(data);
        debugPrint('✅ Parsed result: isRegistered=${_verificationResult!.isRegistered}');
        return _verificationResult!;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      debugPrint('=== NETWORK DEBUG ERROR ===');
      debugPrint('❌ Exception type: ${e.runtimeType}');
      debugPrint('❌ Exception message: $e');
      
      // More detailed error analysis
      if (e is DioException) {
        debugPrint('🔍 DioException details:');
        debugPrint('   - Type: ${e.type}');
        debugPrint('   - Message: ${e.message}');
        debugPrint('   - Error: ${e.error}');
        debugPrint('   - Response: ${e.response}');
        debugPrint('   - Request options: ${e.requestOptions}');
        
        // Check specific error types
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            debugPrint('🔥 CONNECTION TIMEOUT: Could not connect to server');
            break;
          case DioExceptionType.receiveTimeout:
            debugPrint('🔥 RECEIVE TIMEOUT: Server did not respond in time');
            break;
          case DioExceptionType.sendTimeout:
            debugPrint('🔥 SEND TIMEOUT: Could not send request in time');
            break;
          case DioExceptionType.badResponse:
            debugPrint('🔥 BAD RESPONSE: Server returned error status');
            break;
          case DioExceptionType.cancel:
            debugPrint('🔥 CANCELLED: Request was cancelled');
            break;
          case DioExceptionType.connectionError:
            debugPrint('🔥 CONNECTION ERROR: Network connection failed');
            debugPrint('   - Possible causes: No internet, DNS issues, server down');
            break;
          case DioExceptionType.badCertificate:
            debugPrint('🔥 BAD CERTIFICATE: SSL/TLS certificate error');
            break;
          case DioExceptionType.unknown:
            debugPrint('🔥 UNKNOWN ERROR: ${e.error}');
            break;
        }
      }
      
      debugPrint('=== NETWORK DEBUG END ===');
      
      final error = PhoneVerificationResult(
        isRegistered: false,
        isAccessExpired: false,
        daysSinceRegistration: 0,
        remainingDays: 0,
        error: e.toString(),
      );
      
      // Provide more specific error message based on error type
      String userError = 'Error de conexión: ';
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.connectionError:
            userError += 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
            break;
          case DioExceptionType.receiveTimeout:
            userError += 'El servidor no respondió a tiempo. Inténtalo más tarde.';
            break;
          default:
            userError += e.message ?? 'Error desconocido';
        }
      } else {
        userError += e.toString();
      }
      
      setError(userError);
      return error;
    } finally {
      setLoading(false);
    }
  }
  
  // Generate ManyChat signup link
  String generateManyChatSignupLink() {
    return 'https://ig.me/m/akilainstitute?text=REGISTRO_YOGA_CHALLENGE';
  }
  
  // Open WhatsApp support
  String generateWhatsAppSupportLink() {
    final message = Uri.encodeComponent('SOPORTE_APP_EXPIRADA');
    return 'https://wa.me/${AppConfig.whatsappNumber}?text=$message';
  }
  
  // Open Instagram community
  String getInstagramCommunityLink() {
    return AppConfig.instagramUrl;
  }
  
  // Generate video token for secure access - matches Android ManyChatIntegration.getVideoToken
  Future<String?> getVideoToken(String phoneNumber) async {
    try {
      final encodedPhone = Uri.encodeComponent(phoneNumber);
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      
      final response = await dio.get('${AppConfig.apiBaseUrl}/get-video-token.php?phone=$encodedPhone');
      
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data['success'] == true && data['token'] != null) {
          return data['token'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting video token: $e');
      return null;
    }
  }
  
  // Build hybrid video URL - matches Android ManyChatIntegration.buildHybridVideoUrl exactly
  String buildHybridVideoUrl(String videoId, String token, String phoneNumber) {
    // Encode phone number for URL (replace + with %2B)
    final encodedPhone = phoneNumber.replaceAll('+', '%2B');
    // Build hybrid URL: /watch/?video=day1&token=abc&phone=123 → validates → /desafio?o=Za1/
    return '${AppConfig.videoBaseUrl}?video=$videoId&token=$token&phone=$encodedPhone';
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


