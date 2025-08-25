import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/yoga_message.dart';
import '../utils/constants.dart';

enum AppScreen {
  splash,
  welcome,
  phoneEntry,
  introVideo,
  welcomeJourney,
  daySelection,
  dashboard,
  challengeComplete,
}

class AppState extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.splash;
  bool _isLoading = false;
  String? _errorMessage;
  
  // User data
  String? _userPhone;
  DateTime? _challengeStartDate;
  bool _introCompleted = false;
  Map<String, String> _selectedSchedule = {};
  int _selectedFrequency = 2;
  List<YogaMessage> _userScheduledMessages = [];
  
  // Progress tracking
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<String> _practiceCompletions = [];
  int _remainingAccessDays = 40;
  
  // Getters
  AppScreen get currentScreen => _currentScreen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userPhone => _userPhone;
  DateTime? get challengeStartDate => _challengeStartDate;
  bool get introCompleted => _introCompleted;
  Map<String, String> get selectedSchedule => _selectedSchedule;
  int get selectedFrequency => _selectedFrequency;
  List<YogaMessage> get userScheduledMessages => _userScheduledMessages;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<String> get practiceCompletions => _practiceCompletions;
  int get remainingAccessDays => _remainingAccessDays;
  
  // Check if challenge has expired
  bool get isChallengeExpired {
    if (_challengeStartDate == null) return false;
    final now = DateTime.now();
    final expiryDate = _challengeStartDate!.add(Duration(days: AppConfig.accessLimitDays));
    return now.isAfter(expiryDate);
  }
  
  // Check if user has completed onboarding
  bool get hasCompletedOnboarding {
    return _userPhone != null && _introCompleted && _selectedSchedule.isNotEmpty;
  }
  
  AppState() {
    _loadUserData();
  }
  
  // Screen navigation
  void setScreen(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  // User data management
  void setUserPhone(String phone) {
    _userPhone = phone;
    _saveUserData();
    notifyListeners();
  }
  
  void setChallengeStartDate(DateTime date) {
    _challengeStartDate = date;
    _saveUserData();
    notifyListeners();
  }
  
  void setIntroCompleted(bool completed) {
    _introCompleted = completed;
    _saveUserData();
    notifyListeners();
  }
  
  void setSelectedSchedule(Map<String, String> schedule) {
    _selectedSchedule = schedule;
    _saveUserData();
    notifyListeners();
  }
  
  void setSelectedFrequency(int frequency) {
    _selectedFrequency = frequency;
    _saveUserData();
    notifyListeners();
  }
  
  void setUserScheduledMessages(List<YogaMessage> messages) {
    _userScheduledMessages = messages;
    notifyListeners();
  }
  
  void setRemainingAccessDays(int days) {
    _remainingAccessDays = days;
    _saveUserData();
    notifyListeners();
  }
  
  // Progress tracking
  void setCurrentStreak(int streak) {
    _currentStreak = streak;
    _longestStreak = streak > _longestStreak ? streak : _longestStreak;
    _saveUserData();
    notifyListeners();
  }
  
  void setLongestStreak(int streak) {
    _longestStreak = streak;
    _saveUserData();
    notifyListeners();
  }
  
  void addPracticeCompletion(String date) {
    if (!_practiceCompletions.contains(date)) {
      _practiceCompletions.add(date);
      _saveUserData();
      notifyListeners();
    }
  }
  
  void removePracticeCompletion(String date) {
    _practiceCompletions.remove(date);
    _saveUserData();
    notifyListeners();
  }
  
  bool isPracticeCompletedForDate(String date) {
    return _practiceCompletions.contains(date);
  }
  
  // Get today's message
  YogaMessage? getTodaysMessage() {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    return _userScheduledMessages.firstWhere(
      (message) {
        final messageDate = "${message.scheduledDate.year}-${message.scheduledDate.month.toString().padLeft(2, '0')}-${message.scheduledDate.day.toString().padLeft(2, '0')}";
        return messageDate == todayStr;
      },
      orElse: () => _userScheduledMessages.first,
    );
  }
  
  // Get next message
  YogaMessage? getNextMessage() {
    final now = DateTime.now();
    final futureMessages = _userScheduledMessages.where((message) => message.scheduledDate.isAfter(now)).toList();
    return futureMessages.isNotEmpty ? futureMessages.first : null;
  }
  
  // Calculate progress percentage
  int getProgressPercentage() {
    if (_userScheduledMessages.isEmpty) return 0;
    
    final now = DateTime.now();
    final completedMessages = _userScheduledMessages.where((message) => message.scheduledDate.isBefore(now)).length;
    final totalMessages = _userScheduledMessages.length;
    
    return ((completedMessages / totalMessages) * 100).round();
  }
  
  // Check app state and navigate accordingly
  void checkAppState() {
    if (isChallengeExpired) {
      setScreen(AppScreen.challengeComplete);
    } else if (hasCompletedOnboarding) {
      setScreen(AppScreen.dashboard);
    } else if (_userPhone != null && _selectedSchedule.isNotEmpty) {
      if (_introCompleted) {
        setScreen(AppScreen.dashboard);
      } else {
        setScreen(AppScreen.introVideo);
      }
    } else if (_userPhone != null) {
      setScreen(AppScreen.introVideo);
    } else {
      setScreen(AppScreen.welcome);
    }
  }
  
  // Reset app state (for testing or logout)
  void resetAppState() {
    _userPhone = null;
    _challengeStartDate = null;
    _introCompleted = false;
    _selectedSchedule.clear();
    _selectedFrequency = 2;
    _userScheduledMessages.clear();
    _currentStreak = 0;
    _longestStreak = 0;
    _practiceCompletions.clear();
    _remainingAccessDays = 40;
    
    _saveUserData();
    setScreen(AppScreen.welcome);
  }
  
  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _userPhone = prefs.getString('user_phone');
      _introCompleted = prefs.getBool('intro_completed') ?? false;
      _selectedFrequency = prefs.getInt('selected_frequency') ?? 2;
      _currentStreak = prefs.getInt('current_streak') ?? 0;
      _longestStreak = prefs.getInt('longest_streak') ?? 0;
      _remainingAccessDays = prefs.getInt('remaining_access_days') ?? 40;
      
      final startDateMillis = prefs.getInt('challenge_start_date');
      if (startDateMillis != null) {
        _challengeStartDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
      }
      
      final scheduleJson = prefs.getString('selected_days');
      if (scheduleJson != null) {
        // Parse schedule JSON (simplified for now)
        _selectedSchedule = {}; // TODO: Implement JSON parsing
      }
      
      final completionsJson = prefs.getString('practice_completions');
      if (completionsJson != null) {
        // Parse completions JSON (simplified for now)
        _practiceCompletions = []; // TODO: Implement JSON parsing
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }
  
  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_userPhone != null) {
        await prefs.setString('user_phone', _userPhone!);
      }
      
      await prefs.setBool('intro_completed', _introCompleted);
      await prefs.setInt('selected_frequency', _selectedFrequency);
      await prefs.setInt('current_streak', _currentStreak);
      await prefs.setInt('longest_streak', _longestStreak);
      await prefs.setInt('remaining_access_days', _remainingAccessDays);
      
      if (_challengeStartDate != null) {
        await prefs.setInt('challenge_start_date', _challengeStartDate!.millisecondsSinceEpoch);
      }
      
      // TODO: Save schedule and completions as JSON
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }
}
