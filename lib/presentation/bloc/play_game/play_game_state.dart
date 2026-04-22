part of 'play_game_bloc.dart';

abstract class PlayGameState extends Equatable {
  final bool isOpen;
  final bool biddingAllowed;
  final bool canOpen; // ✅ NEW
  final bool canClose; // ✅ NEW
  final AppGame game;

  const PlayGameState({
    required this.isOpen,
    required this.biddingAllowed,
    required this.canOpen,
    required this.canClose,
    required this.game,
  });

  @override
  List<Object?> get props => [isOpen, biddingAllowed, canOpen, canClose, game];
}

// ================== LOADED ==================

class PlayGameLoaded extends PlayGameState {
  const PlayGameLoaded({
    required super.isOpen,
    required super.game,
    required super.biddingAllowed,
    required super.canOpen,
    required super.canClose,
  });
}

// ================== LOADING ==================

class PlayGameLoading extends PlayGameState {
  const PlayGameLoading({
    required super.isOpen,
    required super.game,
    required super.biddingAllowed,
    required super.canOpen,
    required super.canClose,
  });
}

// ================== SUCCESS ==================

class PlayGameBidSuccess extends PlayGameState {
  final String message;

  const PlayGameBidSuccess({
    required super.isOpen,
    required super.game,
    required super.biddingAllowed,
    required super.canOpen,
    required super.canClose,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

// ================== ERROR ==================

class PlayGameError extends PlayGameState {
  final String message;

  const PlayGameError({
    required super.isOpen,
    required super.game,
    required super.biddingAllowed,
    required super.canOpen,
    required super.canClose,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
