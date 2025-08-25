import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'YogaChallenge-Flutter/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _verificationResult = PhoneVerificationResult.fromJson(data);
        return _verificationResult!;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
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
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/get-video-token.php?phone=$encodedPhone'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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


