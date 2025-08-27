import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import '../models/yoga_message.dart';
import '../utils/constants.dart';
import '../utils/build_info.dart';

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
    
    List<String> testResults = [];
    
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
      
      // Multiple connectivity tests
      
      // Test 1: HTTPS Google
      try {
        final testDio = Dio();
        testDio.options.connectTimeout = const Duration(seconds: 5);
        await testDio.get('https://www.google.com');
        testResults.add('✅ HTTPS Google: OK');
      } catch (e) {
        testResults.add('❌ HTTPS Google: ${e.runtimeType}');
      }
      
      // Test 2: HTTP (insecure)
      try {
        final testDio = Dio();
        testDio.options.connectTimeout = const Duration(seconds: 5);
        await testDio.get('http://httpbin.org/get');
        testResults.add('✅ HTTP: OK');
      } catch (e) {
        testResults.add('❌ HTTP: ${e.runtimeType}');
      }
      
      // Test 3: Our API domain (HTTPS)
      try {
        final testDio = Dio();
        testDio.options.connectTimeout = const Duration(seconds: 5);
        await testDio.get('https://akilainstitute.com/');
        testResults.add('✅ akilainstitute.com: OK');
      } catch (e) {
        testResults.add('❌ akilainstitute.com: ${e.runtimeType}');
      }
      
      debugPrint('Connectivity Test Results: ${testResults.join(', ')}');
      
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
      
      // Handle SSL certificate issues that might cause RSA signature failures
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          debugPrint('🔒 Phone verification SSL Certificate callback for $host:$port');
          debugPrint('🔒 ALLOWING connection for development/testing - RSA signature issues');
          return true; // Allow connection for development/testing
        };
        return client;
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
        debugPrint('✅ Parsed result: registered=${_verificationResult!.registered}, days_remaining=${_verificationResult!.daysRemaining}');
        debugPrint('✅ User: ${_verificationResult!.name}, Phone: ${_verificationResult!.phone}');
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
        registered: false,
        isAccessExpired: false,
        daysSinceRegistration: 0,
        daysRemaining: 0,
        error: e.toString(),
      );
      
      // Provide more specific error message based on error type
      String userError = 'NETWORK ERROR v1.1.41:\n';
      String debugInfo = '';
      
      // Show connectivity test results in error
      if (testResults.isNotEmpty) {
        debugInfo = '\n\n[CONNECTIVITY TESTS]\n${testResults.join('\n')}\n';
      }
      
      if (e is DioException) {
        debugInfo += '\n[API ERROR]\n';
        debugInfo += 'Type: ${e.type}\n';
        debugInfo += 'Message: ${e.message}\n';
        
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.connectionError:
            userError += 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
            debugInfo += 'CONNECTION FAILED - Check iOS network settings';
            break;
          case DioExceptionType.receiveTimeout:
            userError += 'El servidor no respondió a tiempo. Inténtalo más tarde.';
            debugInfo += 'TIMEOUT - Server not responding';
            break;
          case DioExceptionType.badCertificate:
            userError += 'Error de certificado SSL.';
            debugInfo += 'SSL/TLS ERROR - Certificate issue';
            break;
          default:
            userError += e.message ?? 'Error desconocido';
            debugInfo += 'Unknown error type';
        }
      } else {
        userError += e.toString();
        debugInfo = '\n\n[DEBUG]\n$e';
      }
      
      // Include debug info in the error message for visibility
      setError(userError + debugInfo);
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
      // Match Android: only encode + sign, keep everything else as-is
      final encodedPhone = phoneNumber.replaceAll('+', '%2B');
      
      // Use dart:developer logging for better iOS visibility
      developer.log('=== v1.1.41 SETSTATE FIX + BUILD CACHE DEBUG ===', name: 'VideoToken');
      developer.log('APP VERSION: v1.1.41 - setState fix + completada behavior + iOS endpoints', name: 'VideoToken');
      developer.log('BUILD IDENTIFIER: ${BuildInfo.getBuildIdentifier()}', name: 'VideoToken');
      developer.log('BUILD INFO VERSION: ${BuildInfo.version}', name: 'VideoToken');
      developer.log('TOKEN PREFIX SHOULD BE: ${BuildInfo.generateTokenPrefix()}', name: 'VideoToken');
      developer.log('Requesting token for phone: $phoneNumber', name: 'VideoToken');
      developer.log('Encoded phone: $encodedPhone', name: 'VideoToken');
      developer.log('Using iOS endpoint: ${AppConfig.getVideoTokenUrl}', name: 'VideoToken');
      developer.log('Expected iOS endpoint: https://akilainstitute.com/api/yoga/ios-get-video-token.php', name: 'VideoToken');
      developer.log('Full URL: ${AppConfig.getVideoTokenUrl}?phone=$encodedPhone', name: 'VideoToken');
      developer.log('Token format expected: token_abc123 (NOT ios_token_abc123)', name: 'VideoToken');
      
      final dio = Dio();
      
      // More aggressive timeout for network issues
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      dio.options.sendTimeout = const Duration(seconds: 15);
      
      // Add headers to match Android exactly
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'YogaChallenge-Flutter/1.0',
      };
      
      // Handle SSL certificate issues that might cause RSA signature failures
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          developer.log('🔒 SSL Certificate callback triggered for $host:$port', name: 'VideoToken');
          developer.log('🔒 Certificate subject: ${cert.subject}', name: 'VideoToken');
          developer.log('🔒 Certificate issuer: ${cert.issuer}', name: 'VideoToken');
          developer.log('🔒 ALLOWING connection for development/testing', name: 'VideoToken');
          return true; // Allow connection for development/testing - RSA signature issues
        };
        return client;
      };
      
      developer.log('Making HTTP request...', name: 'VideoToken');
      final response = await dio.get('${AppConfig.getVideoTokenUrl}?phone=$encodedPhone');
      
      developer.log('Response status: ${response.statusCode}', name: 'VideoToken');
      developer.log('Response headers: ${response.headers}', name: 'VideoToken');
      developer.log('Response data: ${response.data}', name: 'VideoToken');
      
      // Check ALL response scenarios
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        developer.log('Parsed data: $data', name: 'VideoToken');
        
        if (data['success'] == true && data['token'] != null) {
          final token = data['token'];
          developer.log('✅ v1.1.41 Token received: $token', name: 'VideoToken');
          developer.log('✅ Token format check: ${token.startsWith('token_') ? 'CORRECT (token_)' : 'INCORRECT (${token.substring(0, 10)}...)'}', name: 'VideoToken');
          return token;
        } else {
          developer.log('❌ Server returned success=false or null token', name: 'VideoToken');
          developer.log('Success field: ${data['success']}', name: 'VideoToken');
          developer.log('Token field: ${data['token']}', name: 'VideoToken');
          developer.log('Error details: ${data['error'] ?? 'No error message'}', name: 'VideoToken');
        }
      } else {
        developer.log('❌ HTTP Error: ${response.statusCode}', name: 'VideoToken');
        developer.log('HTTP Error message: ${response.statusMessage}', name: 'VideoToken');
      }
      return null;
    } catch (e) {
      developer.log('❌ Exception caught: $e', name: 'VideoToken');
      if (e is DioException) {
        developer.log('DioException type: ${e.type}', name: 'VideoToken');
        developer.log('DioException message: ${e.message}', name: 'VideoToken');
        developer.log('DioException response: ${e.response?.data}', name: 'VideoToken');
        developer.log('DioException status code: ${e.response?.statusCode}', name: 'VideoToken');
        
        // Special handling for SSL/certificate errors that might cause RSA signature failures
        if (e.type == DioExceptionType.badCertificate) {
          developer.log('❌ SSL Certificate verification failed - this may relate to RSA signature errors in iOS logs', name: 'VideoToken');
        } else if (e.type == DioExceptionType.connectionError) {
          developer.log('❌ Connection error - network or DNS issue', name: 'VideoToken');
        } else if (e.type == DioExceptionType.connectionTimeout) {
          developer.log('❌ Connection timeout - server not responding', name: 'VideoToken');
        }
      }
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





