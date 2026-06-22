import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_all_logs_usecase.dart';
import '../../domain/usecases/clear_all_logs_usecase.dart';
import '../../core/providers/global_providers.dart';

class LogsState {
  final List<LocationEntity> logs;
  final bool isLoading;
  final String? error;

  LogsState({this.logs = const [], this.isLoading = false, this.error});

  LogsState copyWith({
    List<LocationEntity>? logs,
    bool? isLoading,
    String? error,
  }) {
    return LogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LogsNotifier extends StateNotifier<LogsState> {
  final GetAllLogsUseCase getAllLogsUseCase;
  final ClearAllLogsUseCase clearAllLogsUseCase;

  LogsNotifier({
    required this.getAllLogsUseCase,
    required this.clearAllLogsUseCase,
  }) : super(LogsState()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await getAllLogsUseCase();
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await clearAllLogsUseCase();
      state = state.copyWith(logs: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final logsProvider = StateNotifierProvider<LogsNotifier, LogsState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  final getAll = GetAllLogsUseCase(repository);
  final clearAll = ClearAllLogsUseCase(repository);
  return LogsNotifier(
    getAllLogsUseCase: getAll,
    clearAllLogsUseCase: clearAll,
  );
});
