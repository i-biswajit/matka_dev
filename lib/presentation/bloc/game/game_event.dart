part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {}

class LoadGames extends GameEvent {
  final int gameId;
  LoadGames(this.gameId);

  @override
  List<Object?> get props => [gameId];
}

class GameSelected extends GameEvent {
  final GameModel marketGame;
  final AppGame game;

  GameSelected({
    required this.marketGame,
    required this.game,
  });
  @override
  List<Object?> get props => [marketGame, game];
}
