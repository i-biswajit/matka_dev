import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/data/models/app_game_model.dart';
import 'package:matka_dev/data/models/game_model.dart';
import 'package:matka_dev/data/repositories/game_repository.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository repository;

  GameBloc({required this.repository}) : super(GameInitial()) {
    on<LoadGames>(_onLoadGames);
    on<GameSelected>(_onGameSelected);
  }

  Future<void> _onLoadGames(LoadGames event, Emitter<GameState> emit) async {
    emit(GameLoading());
    try {
      final games = await repository.fetchAppGames(gameId: event.gameId);
      emit(GameLoaded(games: games));
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void _onGameSelected(GameSelected event, Emitter emit) {
    emit(GameNavigate(
      marketGame: event.marketGame,
      playType: event.game,
    ));

    // restore UI
    emit(state);
  }
}
