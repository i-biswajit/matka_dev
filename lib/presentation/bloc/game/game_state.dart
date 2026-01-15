abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameLoaded extends GameState {
  final List<Map<String, dynamic>> games;

  GameLoaded({required this.games});
}
