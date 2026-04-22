part of 'add_funds_history_bloc.dart';

abstract class AddFundHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddFundHistoryInitial extends AddFundHistoryState {}

class AddFundHistoryLoading extends AddFundHistoryState {}

class AddFundHistoryLoaded extends AddFundHistoryState {
  final List<AddFundHistoryModel> history;

  AddFundHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class AddFundHistoryError extends AddFundHistoryState {
  final String message;

  AddFundHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
