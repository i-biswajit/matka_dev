import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matka_dev/data/models/game_rate_model.dart';
import 'package:matka_dev/data/repositories/game_rate_repository.dart';

part 'game_rate_event.dart';
part 'game_rate_state.dart';

class GameRateBloc extends Bloc<GameRateEvent, GameRateState> {
  final GameRateRepository repository;

  GameRateBloc({required this.repository}) : super(GameRateInitial()) {
    on<LoadGameRates>((event, emit) async {
      emit(GameRateLoading());
      try {
        final rates = await repository.fetchRates();
        emit(GameRateLoaded(rates));
      } catch (e) {
        emit(GameRateError(e.toString()));
      }
    });
  }
}
