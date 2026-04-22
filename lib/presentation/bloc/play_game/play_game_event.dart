part of 'play_game_bloc.dart';

abstract class PlayGameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleOpenClose extends PlayGameEvent {
  final bool isOpen;
  ToggleOpenClose(this.isOpen);

  @override
  List<Object?> get props => [isOpen];
}

class CheckTime extends PlayGameEvent {}

class PlaceBid extends PlayGameEvent {
  final int gameId;
  final String date;
  final String bidTime; // "open" or "close"
  final String gameType;
  final String digit;
  final String amount;

  PlaceBid({
    required this.gameId,
    required this.date,
    required this.bidTime,
    required this.gameType,
    required this.digit,
    required this.amount,
  });

  @override
  List<Object?> get props => [gameId, date, bidTime, gameType, digit, amount];
}
