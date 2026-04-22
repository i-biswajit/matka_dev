part of 'win_history_bloc.dart';

abstract class WinHistoryState {}

class WinHistoryInitial extends WinHistoryState {}

class WinHistoryLoading extends WinHistoryState {}

class WinHistoryLoaded extends WinHistoryState {
  final List<WinHistory> list;
  WinHistoryLoaded(this.list);
}

class WinHistoryError extends WinHistoryState {
  final String message;
  WinHistoryError(this.message);
}
