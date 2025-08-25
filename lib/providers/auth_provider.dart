import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      final response = await http.post(
        Uri.parse(AppConfig.checkPhoneUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'app': 'yoga_challenge_flutter',
        }),
      );
      
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
