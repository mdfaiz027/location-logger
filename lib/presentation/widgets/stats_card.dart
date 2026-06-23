import 'package:flutter/material.dart';
import 'package:location_logger_app/core/constants/app_colors.dart';
import 'package:location_logger_app/core/utils/distance_utils.dart';

class StatsCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final int totalPoints;
  final double totalDistance;

  const StatsCard({
    super.key,
    this.latitude,
    this.longitude,
    required this.totalPoints,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Latitude',
                value: latitude?.toStringAsFixed(6) ?? '--',
                icon: Icons.location_on_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBox(
                label: 'Longitude',
                value: longitude?.toStringAsFixed(6) ?? '--',
                icon: Icons.explore_outlined,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Points Logged',
                value: totalPoints.toString(),
                icon: Icons.data_usage_rounded,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBox(
                label: 'Distance',
                value: DistanceUtils.formatDistance(totalDistance),
                icon: Icons.straighten_rounded,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
