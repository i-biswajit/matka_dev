import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matka_dev/data/models/app_game_model.dart';
import 'package:matka_dev/data/models/game_model.dart';
import 'package:matka_dev/data/repositories/bid_repository.dart';

part 'play_game_event.dart';
part 'play_game_state.dart';

class PlayGameBloc extends Bloc<PlayGameEvent, PlayGameState> {
  final GameModel marketGame;
  final AppGame playType;
  final BidRepository repository;

  bool isOpen = true;
  Timer? _timer;

  PlayGameBloc({
    required this.marketGame,
    required this.playType,
    required this.repository,
  }) : super(PlayGameLoaded(
          isOpen: true,
          biddingAllowed: false,
          canOpen: false,
          canClose: false,
          game: playType,
        )) {
    on<ToggleOpenClose>(_onToggle);
    on<CheckTime>(_onCheckTime);
    on<PlaceBid>(_onPlaceBid);

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(CheckTime());
    });

    add(CheckTime());
  }

  // ================== TOGGLE ==================

  void _onToggle(ToggleOpenClose event, Emitter<PlayGameState> emit) {
    final canOpen = _canPlayOpen();
    final canClose = _canPlayClose();

    if (event.isOpen && !canOpen) {
      emit(PlayGameError(
        isOpen: isOpen,
        biddingAllowed: false,
        canOpen: canOpen,
        canClose: canClose,
        game: playType,
        message: "Open bidding is closed",
      ));
      return;
    }

    if (!event.isOpen && !canClose) {
      emit(PlayGameError(
        isOpen: isOpen,
        biddingAllowed: false,
        canOpen: canOpen,
        canClose: canClose,
        game: playType,
        message: "Close bidding is closed",
      ));
      return;
    }

    isOpen = event.isOpen;

    emit(PlayGameLoaded(
      isOpen: isOpen,
      biddingAllowed: true,
      canOpen: canOpen,
      canClose: canClose,
      game: playType,
    ));
  }

  // ================== TIME CHECK ==================

  void _onCheckTime(CheckTime event, Emitter<PlayGameState> emit) {
    final canOpen = _canPlayOpen();
    final canClose = _canPlayClose();
    final allowed = canOpen || canClose;

    // Auto switch tab
    if (isOpen && !canOpen && canClose) {
      isOpen = false;
    } else if (!isOpen && !canClose && canOpen) {
      isOpen = true;
    }

    emit(
      PlayGameLoaded(
        isOpen: isOpen,
        biddingAllowed: allowed,
        canOpen: canOpen,
        canClose: canClose,
        game: playType,
      ),
    );
  }

  // ================== PLACE BID ==================

  Future<void> _onPlaceBid(
    PlaceBid event,
    Emitter<PlayGameState> emit,
  ) async {
    final canOpen = _canPlayOpen();
    final canClose = _canPlayClose();

    // 🔴 OPEN CHECK
    if (event.bidTime == "open" && !canOpen) {
      emit(PlayGameError(
        isOpen: isOpen,
        biddingAllowed: false,
        canOpen: canOpen,
        canClose: canClose,
        game: playType,
        message: "Open bidding is closed",
      ));
      return;
    }

    // 🔴 CLOSE CHECK
    if (event.bidTime == "close" && !canClose) {
      emit(PlayGameError(
        isOpen: isOpen,
        biddingAllowed: false,
        canOpen: canOpen,
        canClose: canClose,
        game: playType,
        message: "Close bidding is closed",
      ));
      return;
    }

    emit(PlayGameLoading(
      isOpen: isOpen,
      biddingAllowed: true,
      canOpen: canOpen,
      canClose: canClose,
      game: playType,
    ));

    try {
      final success = await repository.placeBid(
        gameId: event.gameId,
        date: event.date,
        bidTime: event.bidTime,
        gameType: event.gameType,
        digit: event.digit,
        amount: event.amount,
      );

      if (success) {
        emit(PlayGameBidSuccess(
          isOpen: isOpen,
          biddingAllowed: true,
          canOpen: canOpen,
          canClose: canClose,
          game: playType,
          message: "Bid placed successfully",
        ));
      } else {
        emit(PlayGameError(
          isOpen: isOpen,
          biddingAllowed: true,
          canOpen: canOpen,
          canClose: canClose,
          game: playType,
          message: "Failed to place bid",
        ));
      }
    } catch (e) {
      emit(PlayGameError(
        isOpen: isOpen,
        biddingAllowed: false,
        canOpen: canOpen,
        canClose: canClose,
        game: playType,
        message: e.toString(),
      ));
    }
  }

  // ================== TIME HELPERS ==================

  bool _isBeforeOpenTime() {
    final now = DateTime.now();
    final parts = marketGame.openTime.split(":");

    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return now.isBefore(openTime);
  }

  bool _isAfterCloseTime() {
    final now = DateTime.now();

    final closeParts = marketGame.closeTime.split(":");
    final closeHour = int.parse(closeParts[0]);
    final closeMinute = int.parse(closeParts[1]);

    DateTime closeTime;

    if (closeHour == 0 && closeMinute == 0) {
      closeTime = DateTime(now.year, now.month, now.day + 1, 0, 0);
    } else if (closeHour < int.parse(marketGame.openTime.split(":")[0])) {
      closeTime =
          DateTime(now.year, now.month, now.day + 1, closeHour, closeMinute);
    } else {
      closeTime =
          DateTime(now.year, now.month, now.day, closeHour, closeMinute);
    }

    return now.isAfter(closeTime);
  }

  // ================== RESULT HELPERS ==================

  bool _isOpenResultDeclared() {
    return marketGame.result?.openDigit != null ||
        marketGame.result?.openPanna != null;
  }

  bool _isCloseResultDeclared() {
    return marketGame.result?.closeDigit != null ||
        marketGame.result?.closePanna != null;
  }

  // ================== PERMISSION LOGIC ==================

  bool _canPlayOpen() {
    if (_isAfterCloseTime()) return false;
    if (_isOpenResultDeclared()) return false;
    if (!_isBeforeOpenTime()) return false;

    return true;
  }

  bool _canPlayClose() {
    if (_isAfterCloseTime()) return false;
    if (_isCloseResultDeclared()) return false;

    return true;
  }

  // ================== CLEANUP ==================

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  bool canPlayOpen() => _canPlayOpen();
  bool canPlayClose() => _canPlayClose();
}
