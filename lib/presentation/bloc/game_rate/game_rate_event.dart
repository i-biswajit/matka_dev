part of 'game_rate_bloc.dart';

abstract class GameRateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGameRates extends GameRateEvent {}
