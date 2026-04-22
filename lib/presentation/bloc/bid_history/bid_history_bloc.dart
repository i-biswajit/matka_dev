import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:matka_dev/data/models/bid_history_model.dart';
import 'package:matka_dev/data/repositories/bid_history_repository.dart';

part 'bid_history_event.dart';
part 'bid_history_state.dart';

class BidHistoryBloc extends Bloc<BidHistoryEvent, BidHistoryState> {
  final BidHistoryRepository repository;

  BidHistoryBloc({required this.repository}) : super(BidHistoryInitial()) {
    on<LoadBidHistory>((event, emit) async {
      emit(BidHistoryLoading());
      try {
        final bids = await repository.fetchBidHistory();
        emit(BidHistoryLoaded(bids));
      } catch (e) {
        emit(BidHistoryError(e.toString()));
      }
    });
  }
}
