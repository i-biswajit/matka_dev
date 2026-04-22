import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matka_dev/data/models/game_model.dart';
import 'package:matka_dev/data/repositories/game_repository.dart';
import 'package:matka_dev/data/repositories/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GameRepository gameRepository;
  final ProfileRepository profileRepository;

  DashboardBloc({
    required this.gameRepository,
    required this.profileRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<DashboardLogoutRequested>(_onLogout);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 🔴 NO TOKEN → GO TO LOGIN (DON’T CALL APIs)
    if (token == null || token.isEmpty) {
      emit(DashboardInitial());
      return;
    }

    // 🔹 FIRST LOAD → full loader
    if (state is! DashboardLoaded) {
      emit(DashboardLoading());
    } else {
      // 🔹 REFRESH → keep screen, show overlay loader
      emit((state as DashboardLoaded).copyWith(isRefreshing: true));
    }

    try {
      /// 🔥 CALL PROFILE API EVERY TIME
      final profile = await profileRepository.fetchProfile();

      /// 🔥 SAVE UPDATED BALANCE LOCALLY (optional but useful)
      await prefs.setString('user_balance', profile.balance.toString());
      await prefs.setString('user_name', profile.name);
      await prefs.setString('mobile', profile.mobile);

      final today = DateTime.now().toIso8601String().split('T').first;

      /// 🔹 FETCH GAMES
      final games = await gameRepository.fetchGames(today);

      emit(
        DashboardLoaded(
          userName: profile.name,
          mobile: profile.mobile,
          games: games,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onLogout(
    DashboardLogoutRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(DashboardInitial());
  }
}
