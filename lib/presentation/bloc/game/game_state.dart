part of 'game_bloc.dart';

abstract class GameState extends Equatable {}

class GameInitial extends GameState {
  @override
  List<Object?> get props => [];
}

class GameLoading extends GameState {
  @override
  List<Object?> get props => [];
}

class GameLoaded extends GameState {
  final List<AppGame> games;

  GameLoaded({required this.games});

  @override
  List<Object?> get props => [games];
}

class GameError extends GameState {
  final String message;
  GameError(this.message);

  @override
  List<Object?> get props => [message];
}

class GameNavigate extends GameState {
  final GameModel marketGame;
  final AppGame playType;

  GameNavigate({
    required this.marketGame,
    required this.playType,
  });
  @override
  List<Object?> get props => [marketGame, playType];
}
