import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/usecases/get_session_locations_usecase.dart';
import '../../core/providers/global_providers.dart';
import '../../domain/entities/location_entity.dart';

class LogDetailsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const LogDetailsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<LogDetailsScreen> createState() => _LogDetailsScreenState();
}

class _LogDetailsScreenState extends ConsumerState<LogDetailsScreen> {
  List<LocationEntity>? _locations;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final repository = ref.read(locationRepositoryProvider);
      final useCase = GetSessionLocationsUseCase(repository);
      final locations = await useCase(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journey Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _locations == null || _locations!.isEmpty
                  ? const Center(child: Text('No points found for this journey.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: _locations!.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final log = _locations![_locations!.length - 1 - index];
                        return _PointCard(log: log, index: _locations!.length - index);
                      },
                    ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final LocationEntity log;
  final int index;

  const _PointCard({required this.log, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.latitude.toStringAsFixed(6)}, ${log.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm:ss a').format(log.timestamp),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '#$index',
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
