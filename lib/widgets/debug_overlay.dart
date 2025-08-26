import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class DebugOverlay extends StatelessWidget {
  const DebugOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, appState, __) {
        final debugText = appState.debugStatus;
        final errorText = appState.lastError;
        
        if (debugText.isEmpty && errorText.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          bottom: 50,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: errorText.isNotEmpty 
                ? Colors.red.withOpacity(0.9)
                : Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText.isNotEmpty ? Colors.red : Colors.white,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (debugText.isNotEmpty)
                  Text(
                    'DEBUG: $debugText',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (errorText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ERROR: $errorText',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}