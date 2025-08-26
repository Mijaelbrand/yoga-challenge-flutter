import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
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
    debugPrint('🎯 DaySelectionScreen build() called');
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
                          setState(() {
                            _debugStatus = "Button pressed!";
                          });
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
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
    setState(() {
      _debugStatus = "Validating schedule...";
    });
    
    // Check that selected days have times - like Android version
    final selectedDays = _daySelections.entries.where((e) => e.value).map((e) => e.key).toList();
    final daysWithoutTime = selectedDays.where((day) => _selectedTimes[day] == null).toList();
    
    if (daysWithoutTime.isNotEmpty) {
      setState(() {
        _debugStatus = "Missing times error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una hora para: ${daysWithoutTime.join(", ")}'),
          backgroundColor: AppColors.error,
        ),
      );
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
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setSelectedSchedule(_selectedSchedule);
    appState.setChallengeStartDate(DateTime.now());
    appState.setIntroCompleted(true);
    
    // Generate user messages for the selected schedule  
    setState(() {
      _debugStatus = "Generating messages...";
    });
    
    try {
      await appState.generateUserMessages();
      setState(() {
        _debugStatus = "Messages generated! Count: ${appState.userScheduledMessages.length}";
      });
    } catch (e) {
      setState(() {
        _debugStatus = "Error: $e";
      });
    }
    
    // Force dashboard screen state
    appState.setScreen(AppScreen.dashboard);
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
      (route) => false,
    );
  }
}


