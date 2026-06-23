import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:location_logger_app/core/constants/app_colors.dart';
import 'package:location_logger_app/core/utils/distance_utils.dart';
import 'package:location_logger_app/presentation/providers/location_notifier.dart';
import 'package:location_logger_app/presentation/providers/logs_notifier.dart';
import 'package:location_logger_app/presentation/providers/sessions_notifier.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/session_entity.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionsProvider);
    final logsNotifier = ref.read(logsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journey Logs'),
        actions: [
          if (state.sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
              onPressed: () => _showClearConfirmation(context, ref, logsNotifier),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sessionsProvider.notifier).loadSessions(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.sessions.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    itemCount: state.sessions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      return _SessionCard(session: session);
                    },
                  ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref, LogsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear all logs?'),
        content: const Text('This action cannot be undone and will delete all recorded journeys.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await notifier.clearLogs();
              // Refresh both providers
              ref.read(sessionsProvider.notifier).loadSessions();
              ref.read(locationProvider.notifier).refreshData();
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionEntity session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/logs/${session.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.route_rounded, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(session.startTime),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('h:mm a').format(session.startTime)} - ${session.endTime != null ? DateFormat('h:mm a').format(session.endTime!) : "Active"}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DistanceUtils.formatDistance(session.totalDistance),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${session.pointsCount} pts',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 80, color: AppColors.iconEmpty),
          const SizedBox(height: 16),
          const Text(
            'No journeys yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking to see your logs here.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
