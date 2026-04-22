part of 'bid_history_bloc.dart';

abstract class BidHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BidHistoryInitial extends BidHistoryState {}

class BidHistoryLoading extends BidHistoryState {}

class BidHistoryLoaded extends BidHistoryState {
  final List<BidHistory> bids;
  BidHistoryLoaded(this.bids);
  @override
  List<Object?> get props => [bids];
}

class BidHistoryError extends BidHistoryState {
  final String message;
  BidHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
