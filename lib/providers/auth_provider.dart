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
      debugPrint('📞 Verifying phone: $trimmedPhone');
      debugPrint('🌐 API URL: $url');
      
      // Use Dio HTTP client for better iOS compatibility
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final response = await dio.get(url);
      
      debugPrint('📱 Response status: ${response.statusCode}');
      debugPrint('📱 Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        _verificationResult = PhoneVerificationResult.fromJson(data);
        return _verificationResult!;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      final error = PhoneVerificationResult(
        isRegistered: false,
        isAccessExpired: false,
        daysSinceRegistration: 0,
        remainingDays: 0,
        error: e.toString(),
      );
      setError('Error de conexión: $e');
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


