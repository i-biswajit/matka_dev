import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitial()) {
    on<LoadGames>((event, emit) async {
      emit(GameLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        GameLoaded(
          games: [
            {"name": "Single Digit", "icon": FontAwesomeIcons.diceOne},
            {"name": "Jodi Digit", "icon": FontAwesomeIcons.diceTwo},
            {"name": "Single Panna", "icon": FontAwesomeIcons.square},
            {"name": "Double Panna", "icon": FontAwesomeIcons.squareFull},
            {"name": "Triple Panna", "icon": FontAwesomeIcons.diceThree},
            {"name": "Half Sangam", "icon": FontAwesomeIcons.diceTwo},
            {"name": "Full Sangam", "icon": FontAwesomeIcons.diceTwo},
          ],
        ),
      );
    });
  }
}
