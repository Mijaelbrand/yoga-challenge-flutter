import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  int _nextMessageNumber = 1; // Track which message number to show next
  
  // Debug overlay
  String _debugStatus = '';
  String _lastError = '';
  
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
  String get debugStatus => _debugStatus;
  String get lastError => _lastError;
  int get nextMessageNumber => _nextMessageNumber;
  
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
  
  void setDebugStatus(String status) {
    _debugStatus = status;
    notifyListeners();
  }
  
  void setLastError(String error) {
    _lastError = error;
    _debugStatus = 'ERROR: $error';
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
      // Advance to next message when user completes a practice
      _nextMessageNumber = _practiceCompletions.length + 1;
      _saveUserData();
      notifyListeners();
    }
  }
  
  void removePracticeCompletion(String date) {
    _practiceCompletions.remove(date);
    // Recalculate next message number based on remaining completions
    _nextMessageNumber = _practiceCompletions.length + 1;
    _saveUserData();
    notifyListeners();
  }
  
  bool isPracticeCompletedForDate(String date) {
    return _practiceCompletions.contains(date);
  }
  
  // Get today's message (respects user progress)
  YogaMessage? getTodaysMessage() {
    if (_userScheduledMessages.isEmpty) return null;
    
    // Return the next message the user should see based on their progress
    final availableMessages = _userScheduledMessages.where(
      (message) => message.messageNumber >= _nextMessageNumber
    ).toList();
    
    if (availableMessages.isEmpty) return null;
    
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    try {
      // First, try to find today's scheduled message from available messages
      final todaysMessage = availableMessages.firstWhere(
        (message) {
          final messageDate = "${message.scheduledDate.year}-${message.scheduledDate.month.toString().padLeft(2, '0')}-${message.scheduledDate.day.toString().padLeft(2, '0')}";
          return messageDate == todayStr;
        },
        orElse: () => availableMessages.first, // Return next available message
      );
      
      return todaysMessage;
    } catch (e) {
      return availableMessages.isNotEmpty ? availableMessages.first : null;
    }
  }
  
  // Get next message (respects user progress)
  YogaMessage? getNextMessage() {
    final now = DateTime.now();
    // Only show future messages that the user hasn't completed yet
    final futureMessages = _userScheduledMessages.where((message) => 
      message.scheduledDate.isAfter(now) && message.messageNumber >= _nextMessageNumber
    ).toList();
    return futureMessages.isNotEmpty ? futureMessages.first : null;
  }
  
  // Calculate progress percentage
  int getProgressPercentage() {
    // Use practice completions instead of dates for persistence across reinstalls
    final completedPractices = _practiceCompletions.length;
    return ((completedPractices / 31.0) * 100).round();
  }
  
  // Check app state and navigate accordingly
  void checkAppState() {
    debugPrint('🔍 checkAppState() called');
    debugPrint('   - Challenge expired: $isChallengeExpired');
    debugPrint('   - Completed onboarding: $hasCompletedOnboarding');
    debugPrint('   - User phone: $_userPhone');
    debugPrint('   - Intro completed: $_introCompleted');
    debugPrint('   - Schedule empty: ${_selectedSchedule.isEmpty}');
    
    if (isChallengeExpired) {
      debugPrint('🎯 Navigation: challengeComplete');
      setScreen(AppScreen.challengeComplete);
    } else if (hasCompletedOnboarding) {
      debugPrint('🎯 Navigation: dashboard');
      setScreen(AppScreen.dashboard);
    } else if (_userPhone != null && _selectedSchedule.isNotEmpty) {
      if (_introCompleted) {
        debugPrint('🎯 Navigation: dashboard (intro complete)');
        setScreen(AppScreen.dashboard);
      } else {
        debugPrint('🎯 Navigation: introVideo');
        setScreen(AppScreen.introVideo);
      }
    } else if (_userPhone != null) {
      debugPrint('🎯 Navigation: introVideo (phone only)');
      setScreen(AppScreen.introVideo);
    } else {
      debugPrint('🎯 Navigation: welcome');
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
    _nextMessageNumber = 1;
    
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
      _nextMessageNumber = prefs.getInt('next_message_number') ?? 1;
      
      final startDateMillis = prefs.getInt('challenge_start_date');
      if (startDateMillis != null) {
        _challengeStartDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
      }
      
      final scheduleJson = prefs.getString('selected_days');
      if (scheduleJson != null) {
        try {
          final Map<String, dynamic> decoded = json.decode(scheduleJson);
          _selectedSchedule = decoded.map((key, value) => MapEntry(key, value.toString()));
          debugPrint('✅ Loaded schedule from storage: $_selectedSchedule');
        } catch (e) {
          debugPrint('❌ Error parsing schedule JSON: $e');
          _selectedSchedule = {};
        }
      }
      
      final completionsList = prefs.getStringList('practice_completions');
      if (completionsList != null) {
        _practiceCompletions = completionsList;
      }
      
      // Ensure nextMessageNumber is correctly calculated based on completions
      // If we loaded from storage but it doesn't match completions, recalculate
      if (_nextMessageNumber != _practiceCompletions.length + 1) {
        _nextMessageNumber = _practiceCompletions.length + 1;
        debugPrint('🔢 Recalculated next message number: $_nextMessageNumber based on ${_practiceCompletions.length} completions');
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
      await prefs.setInt('next_message_number', _nextMessageNumber);
      
      if (_challengeStartDate != null) {
        await prefs.setInt('challenge_start_date', _challengeStartDate!.millisecondsSinceEpoch);
      }
      
      // Save practice completions
      await prefs.setStringList('practice_completions', _practiceCompletions);
      
      // Save schedule as JSON
      if (_selectedSchedule.isNotEmpty) {
        await prefs.setString('selected_days', json.encode(_selectedSchedule));
        debugPrint('✅ Saved schedule to storage: $_selectedSchedule');
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }
  
  // Generate user messages based on selected schedule
  Future<void> generateUserMessages() async {
    try {
      debugPrint('🔄 Starting message generation...');
      debugPrint('📅 Schedule: $_selectedSchedule');
      debugPrint('📅 Start date: $_challengeStartDate');
      
      _userScheduledMessages.clear();
      
      if (_selectedSchedule.isEmpty || _challengeStartDate == null) {
        debugPrint('❌ Cannot generate messages: schedule or start date missing');
        debugPrint('   - Schedule empty: ${_selectedSchedule.isEmpty}');
        debugPrint('   - Start date null: ${_challengeStartDate == null}');
        return;
      }
      
      // Load yoga messages from JSON
      debugPrint('🔄 About to load JSON from assets/data/yoga_messages.json');
      Map<String, dynamic> messagesData;
      try {
        final String jsonString = await rootBundle.loadString('assets/data/yoga_messages.json');
        debugPrint('🔄 JSON string loaded, length: ${jsonString.length}');
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        debugPrint('🔄 JSON decoded successfully');
        messagesData = jsonData['messages'];
        debugPrint('✅ JSON loaded successfully: ${messagesData.length} messages');
      } catch (e, stack) {
        debugPrint('❌ JSON loading failed: $e\n$stack');
        rethrow; // Don't use fallback, let it crash to see the real error
      }
      
      // Generate FULL schedule for 31 days but preserve user's progress
      final List<YogaMessage> scheduledMessages = [];
      debugPrint('🔍 Messages data keys: ${messagesData.keys.take(5).toList()}');
      debugPrint('🔢 Next message number: $_nextMessageNumber');
      debugPrint('📊 Practice completions: ${_practiceCompletions.length}');
      
      final startDate = _challengeStartDate!;
      int messageIndex = 1; // Always generate full sequence
      
      for (int day = 0; day < 31 && messageIndex <= messagesData.length; day++) {
        final currentDate = startDate.add(Duration(days: day));
        final dayOfWeek = currentDate.weekday % 7; // Convert to 0-6 format
        
        // Check if this day is in the user's schedule
        final dayShort = _getDayShortFromWeekday(dayOfWeek);
        debugPrint('🗓️ Day $day: $dayShort (weekday: $dayOfWeek) - in schedule: ${_selectedSchedule.containsKey(dayShort)}');
        if (_selectedSchedule.containsKey(dayShort)) {
          final timeString = _selectedSchedule[dayShort]!;
          late final int hour;
          late final int minute;
          
          try {
            final timeParts = timeString.split(':');
            hour = int.parse(timeParts[0]);
            minute = int.parse(timeParts[1]);
          } catch (e) {
            debugPrint('💥 TIME PARSING CRASH: timeString="$timeString", error: $e');
            rethrow;
          }
          
          final scheduledDateTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
          );
          
          // Get message data
          final messageData = messagesData[messageIndex.toString()];
          if (messageData != null) {
            final yogaMessage = YogaMessage(
              messageNumber: messageIndex,
              notificationTitle: messageData['notification_title'] ?? 'Yoga Challenge',
              notificationText: messageData['notification_text'] ?? 'Tu práctica te espera',
              fullMessage: messageData['full_message'] ?? 'Mensaje del día $messageIndex',
              videoUrl: messageData['video_url'] ?? 'day$messageIndex',
              videoButtonText: messageData['video_button_text'] ?? 'Ver video',
              scheduledDate: scheduledDateTime,
            );
            
            scheduledMessages.add(yogaMessage);
            messageIndex++;
          }
        }
      }
      
      _userScheduledMessages = scheduledMessages;
      
      // If no messages were generated, create at least one mock message to prevent grey screen
      if (_userScheduledMessages.isEmpty) {
        debugPrint('⚠️ No messages generated, creating fallback message');
        final fallbackMessage = YogaMessage(
          messageNumber: 1,
          notificationTitle: 'Yoga Challenge',
          notificationText: 'Tu práctica te espera',
          fullMessage: 'Bienvenido a tu desafío de yoga. ¡Comencemos!',
          videoUrl: 'day1',
          videoButtonText: 'Ver video',
          scheduledDate: DateTime.now(),
        );
        _userScheduledMessages.add(fallbackMessage);
      }
      
      await _saveUserData();
      notifyListeners();
      
      debugPrint('✅ Generated ${_userScheduledMessages.length} messages for user schedule');
      
    } catch (e, stack) {
      debugPrint('❌ CRITICAL: generateUserMessages error: $e\n$stack');
      rethrow; // Let Flutter show the actual crash instead of hiding it
    }
  }
  
  // Helper method to convert weekday to short day name
  String _getDayShortFromWeekday(int weekday) {
    const dayShorts = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return dayShorts[weekday];
  }
}




