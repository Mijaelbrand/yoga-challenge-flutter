import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

class DaySelectionScreen extends StatefulWidget {
  const DaySelectionScreen({super.key});

  @override
  State<DaySelectionScreen> createState() => _DaySelectionScreenState();
}

class _DaySelectionScreenState extends State<DaySelectionScreen> {
  final Map<String, String> _selectedSchedule = {};
  final Map<String, bool> _daySelections = {};
  final Map<String, TimeOfDay?> _selectedTimes = {};
  String _debugStatus = "Ready";

  @override
  void initState() {
    super.initState();
    _initializeDaySelections();
  }

  void _initializeDaySelections() {
    for (int i = 0; i < AppStrings.daysShort.length; i++) {
      final dayShort = AppStrings.daysShort[i];
      _daySelections[dayShort] = false;
      _selectedTimes[dayShort] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    dev.log('🎯 DaySelectionScreen build() called');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(AppStrings.daySelectionTitle),
            Text(
              'Debug: $_debugStatus',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      AppStrings.daySelectionTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      AppStrings.daySelectionSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Days Selection
                    ...AppStrings.daysOfWeek.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final dayShort = AppStrings.daysShort[index];
                      
                      return _buildDaySelectionCard(
                        context,
                        day: day,
                        dayShort: dayShort,
                        isSelected: _daySelections[dayShort] ?? false,
                        selectedTime: _selectedTimes[dayShort],
                        onDaySelected: (selected) {
                          setState(() {
                            _daySelections[dayShort] = selected;
                            if (!selected) {
                              _selectedTimes[dayShort] = null;
                              _selectedSchedule.remove(dayShort);
                            }
                          });
                        },
                        onTimeSelected: (time) {
                          setState(() {
                            _selectedTimes[dayShort] = time;
                            if (time != null) {
                              _selectedSchedule[dayShort] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            } else {
                              _selectedSchedule.remove(dayShort);
                            }
                          });
                        },
                      );
                    }),
                    
                    const SizedBox(height: 32),
                    
                    // Selected Days Summary
                    if (_selectedSchedule.isNotEmpty) _buildSelectedDaysSummary(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Container(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedSchedule.length >= AppConfig.minPracticeDays
                      ? () {
                          if (!mounted) return;
                          try {
                            if (mounted) {
                              setState(() {
                                _debugStatus = "Button pressed!";
                              });
                            }
                          } catch (e, stack) {
                            dev.log('setState failed on button press: $e\n$stack');
                            Provider.of<AppState>(context, listen: false).setLastError('Button setState: $e');
                            rethrow; // Show red screen with stack trace
                          }
                          _confirmSchedule();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    AppStrings.confirmButton,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelectionCard(
    BuildContext context, {
    required String day,
    required String dayShort,
    required bool isSelected,
    required TimeOfDay? selectedTime,
    required Function(bool) onDaySelected,
    required Function(TimeOfDay?) onTimeSelected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) => onDaySelected(value ?? false),
              activeColor: AppColors.primary,
            ),
            
            const SizedBox(width: 12),
            
            // Day Name
            Expanded(
              child: Text(
                day,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            // Time Selection
            if (isSelected) ...[
              const SizedBox(width: 12),
              
              GestureDetector(
                onTap: () => _showTimePicker(context, onTimeSelected),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        selectedTime != null
                            ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                            : AppStrings.selectTime,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDaysSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.messageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de tu horario',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ..._selectedSchedule.entries.map((entry) {
            final dayShort = entry.key;
            final time = entry.value;
            final dayName = AppStrings.daysOfWeek[AppStrings.daysShort.indexOf(dayShort)];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $dayName a las $time',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
          
          const SizedBox(height: 8),
          
          Text(
            'Total: ${_selectedSchedule.length} días por semana',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    Function(TimeOfDay?) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    onTimeSelected(picked);
  }

  Future<void> _confirmSchedule() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Remove debug dialog to prevent context issues
    dev.log('🎯 _confirmSchedule called with schedule: $_selectedSchedule');
    appState.setDebugStatus('Starting schedule confirmation...');
    
    // Add initial delay for safety
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!mounted) return;
    
    // Wrap setState in try-catch for safety
    try {
      if (mounted) {
        setState(() {
          _debugStatus = "Validating schedule...";
        });
        appState.setDebugStatus('Validating schedule...');
      }
    } catch (e, stack) {
      dev.log('setState failed at validation start: $e\n$stack');
      appState.setLastError('setState failed at validation: $e');
      rethrow; // Show red screen with stack trace
    }
    
    // Check that selected days have times - like Android version
    final selectedDays = _daySelections.entries.where((e) => e.value).map((e) => e.key).toList();
    final daysWithoutTime = selectedDays.where((day) => _selectedTimes[day] == null).toList();
    
    if (daysWithoutTime.isNotEmpty) {
      if (!mounted) return;
      try {
        if (mounted) {
          setState(() {
            _debugStatus = "Missing times error";
          });
        }
      } catch (e, stack) {
        dev.log('setState failed for missing times: $e\n$stack');
        appState.setLastError('setState failed for missing times: $e');
        rethrow; // Show red screen with stack trace
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor selecciona una hora para: ${daysWithoutTime.join(", ")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (_selectedSchedule.length < AppConfig.minPracticeDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorMinDays),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedSchedule.length > AppConfig.maxPracticeDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorMaxDays),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Save schedule and navigate to dashboard
    appState.setSelectedSchedule(_selectedSchedule);
    appState.setChallengeStartDate(DateTime.now());
    appState.setIntroCompleted(true);
    
    // Generate user messages for the selected schedule  
    if (!mounted) return;
    
    // Safer setState with try-catch
    try {
      if (mounted) {
        setState(() {
          _debugStatus = "Generating messages...";
        });
      }
    } catch (e, stack) {
      dev.log('setState failed before message generation: $e\n$stack');
      appState.setLastError('setState failed before generation: $e');
      rethrow; // Show red screen with stack trace
    }
    
    try {
      dev.log('🔄 Starting generateUserMessages...');
      appState.setDebugStatus('Generating messages...');
      await appState.generateUserMessages();
      dev.log('✅ generateUserMessages completed');
      appState.setDebugStatus('Messages generated successfully!');
      
      // Schedule notifications for the generated messages
      try {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.scheduleUserNotifications(appState.userScheduledMessages);
        dev.log('✅ Notifications scheduled successfully');
        appState.setDebugStatus('Notifications scheduled!');
      } catch (e, stack) {
        dev.log('❌ Failed to schedule notifications: $e\n$stack');
        appState.setDebugStatus('Warning: Notifications failed to schedule');
        // Don't rethrow - continue with app flow even if notifications fail
      }
      
      if (!mounted) return;
      
      // Add small delay after async operation
      await Future.microtask(() {});
      
      if (mounted) {
        try {
          setState(() {
            _debugStatus = "Messages generated! Count: ${appState.userScheduledMessages.length}";
          });
          appState.setDebugStatus('Messages: ${appState.userScheduledMessages.length}');
        } catch (e, stack) {
          dev.log('setState failed after message generation: $e\n$stack');
          appState.setLastError('setState after generation: $e');
          rethrow; // Show red screen with stack trace
        }
      }
    } catch (e, stack) {
      dev.log('❌ _confirmSchedule error: $e\n$stack');
      appState.setLastError('Message generation failed: $e');
      if (!mounted) return;
      
      try {
        if (mounted) {
          setState(() {
            _debugStatus = "Error: $e";
          });
        }
      } catch (setStateError, setStateStack) {
        dev.log('setState failed in error handler: $setStateError\n$setStateStack');
        appState.setLastError('Error handler setState: $setStateError');
        rethrow; // Show red screen with stack trace
      }
      rethrow; // Show red screen with stack trace
    }
    
    // Force dashboard screen state
    dev.log('🔄 About to set screen to dashboard');
    appState.setDebugStatus('Setting screen to dashboard...');
    appState.setScreen(AppScreen.dashboard);
    
    // Add delay before navigation for safety
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) {
      dev.log('❌ Widget not mounted before navigation');
      appState.setLastError('Widget unmounted before navigation');
      return;
    }
    
    // MULTIPLE NAVIGATION APPROACHES FOR TESTING
    dev.log('🔄 Starting navigation to dashboard');
    appState.setDebugStatus('Starting navigation methods...');
    
    // Approach 1: Post-frame callback (current method)
    dev.log('🔄 Method 1: Post-frame callback navigation');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          dev.log('🔄 PostFrame: Executing navigation to dashboard');
          appState.setDebugStatus('PostFrame: Navigation executing...');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
            (route) => false,
          );
          dev.log('✅ PostFrame: Navigation completed');
          appState.setDebugStatus('PostFrame: Navigation completed!');
        } catch (e, stack) {
          dev.log('❌ PostFrame: Navigation failed: $e\n$stack');
          appState.setLastError('PostFrame navigation failed: $e');
          
          // FALLBACK: Try immediate navigation
          _attemptImmediateNavigation(appState);
        }
      } else {
        dev.log('❌ PostFrame: Widget not mounted');
        appState.setLastError('PostFrame: Widget unmounted');
        
        // FALLBACK: Try scheduler binding
        _attemptSchedulerNavigation(appState);
      }
    });
    
    // Approach 2: Delayed fallback (in case post-frame fails)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        dev.log('🔄 Method 2: Delayed fallback check');
        // Check if we're still on this screen (navigation didn't work)
        if (ModalRoute.of(context)?.settings.name != '/dashboard') {
          appState.setDebugStatus('Delayed fallback: Attempting direct navigation');
          _attemptImmediateNavigation(appState);
        }
      }
    });
    
    // Approach 3: Scheduler binding fallback (for extreme cases)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && ModalRoute.of(context)?.settings.name != '/dashboard') {
            dev.log('🔄 Method 3: Scheduler binding fallback');
            appState.setDebugStatus('Scheduler fallback: Navigation attempt');
            _attemptImmediateNavigation(appState);
          }
        });
      }
    });
  }
  
  // Helper method: Immediate navigation attempt
  void _attemptImmediateNavigation(AppState appState) {
    if (!mounted) {
      dev.log('❌ Immediate navigation: Widget not mounted');
      return;
    }
    
    try {
      dev.log('🔄 Immediate: Attempting direct navigation');
      appState.setDebugStatus('Immediate: Direct navigation attempt');
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
          settings: const RouteSettings(name: '/dashboard'),
        ),
        (route) => false,
      );
      
      dev.log('✅ Immediate: Navigation completed');
      appState.setDebugStatus('Immediate: Navigation SUCCESS!');
    } catch (e, stack) {
      dev.log('❌ Immediate: Navigation failed: $e\n$stack');
      appState.setLastError('Immediate navigation failed: $e');
    }
  }
  
  // Helper method: Scheduler binding navigation
  void _attemptSchedulerNavigation(AppState appState) {
    dev.log('🔄 Scheduler: Attempting scheduler navigation');
    appState.setDebugStatus('Scheduler: Navigation attempt');
    
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
              settings: const RouteSettings(name: '/dashboard'),
            ),
            (route) => false,
          );
          dev.log('✅ Scheduler: Navigation completed');
          appState.setDebugStatus('Scheduler: Navigation SUCCESS!');
        }
      });
    } catch (e, stack) {
      dev.log('❌ Scheduler: Navigation failed: $e\n$stack');
      appState.setLastError('Scheduler navigation failed: $e');
    }
  }
}




