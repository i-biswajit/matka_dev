import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:matka_dev/data/models/add_funds_history_model.dart';
import 'package:matka_dev/data/repositories/add_funds_history_repository.dart';

part 'add_funds_history_event.dart';
part 'add_funds_history_state.dart';

class AddFundHistoryBloc
    extends Bloc<AddFundHistoryEvent, AddFundHistoryState> {
  final AddFundHistoryRepository repository;

  AddFundHistoryBloc({required this.repository})
      : super(AddFundHistoryInitial()) {
    on<FetchAddFundHistory>((event, emit) async {
      emit(AddFundHistoryLoading());
      try {
        final history = await repository.fetchHistory();
        emit(AddFundHistoryLoaded(history));
      } catch (e) {
        emit(AddFundHistoryError(e.toString()));
      }
    });
  }
}
