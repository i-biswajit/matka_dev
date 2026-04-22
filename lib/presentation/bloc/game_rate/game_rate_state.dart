part of 'game_rate_bloc.dart';

abstract class GameRateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GameRateInitial extends GameRateState {}

class GameRateLoading extends GameRateState {}

class GameRateLoaded extends GameRateState {
  final List<GameRateModel> rates;
  GameRateLoaded(this.rates);

  @override
  List<Object?> get props => [rates];
}

class GameRateError extends GameRateState {
  final String message;
  GameRateError(this.message);

  @override
  List<Object?> get props => [message];
}
