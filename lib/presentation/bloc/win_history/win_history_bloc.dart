import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/data/models/win_history_model.dart';
import 'package:matka_dev/data/repositories/win_history_repository.dart';
part 'win_history_event.dart';
part 'win_history_state.dart';

class WinHistoryBloc extends Bloc<WinHistoryEvent, WinHistoryState> {
  final WinHistoryRepository repository;

  WinHistoryBloc({required this.repository}) : super(WinHistoryInitial()) {
    on<LoadWinHistory>((event, emit) async {
      emit(WinHistoryLoading());
      try {
        final bids = await repository.fetchWinHistory();
        emit(WinHistoryLoaded(bids));
      } catch (e) {
        emit(WinHistoryError(e.toString()));
      }
    });
  }
}
