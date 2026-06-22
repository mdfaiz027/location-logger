import 'package:flutter/material.dart';
import 'package:location_logger_app/core/constants/app_colors.dart';
import 'package:location_logger_app/core/constants/app_strings.dart';

class ActionButtons extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ActionButtons({
    super.key,
    required this.isTracking,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isTracking ? onStop : onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: isTracking ? AppColors.errorLight : AppColors.primary,
          foregroundColor: isTracking ? AppColors.error : AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isTracking ? AppStrings.stopTracking : AppStrings.startTracking,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
