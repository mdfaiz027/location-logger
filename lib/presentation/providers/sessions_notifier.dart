import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/get_sessions_usecase.dart';
import '../../core/providers/global_providers.dart';

class SessionsState {
  final List<SessionEntity> sessions;
  final bool isLoading;
  final String? error;

  SessionsState({this.sessions = const [], this.isLoading = false, this.error});

  SessionsState copyWith({
    List<SessionEntity>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return SessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SessionsNotifier extends StateNotifier<SessionsState> {
  final GetSessionsUseCase getSessionsUseCase;

  SessionsNotifier({
    required this.getSessionsUseCase,
  }) : super(SessionsState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await getSessionsUseCase();
      if (!mounted) return;
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final sessionsProvider = StateNotifierProvider.autoDispose<SessionsNotifier, SessionsState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  final getSessions = GetSessionsUseCase(repository);
  return SessionsNotifier(
    getSessionsUseCase: getSessions,
  );
});
