part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardState {
  final int walletBalance;
  final List<String> games;

  DashboardLoaded({
    required this.walletBalance,
    required this.games,
  });

  @override
  List<Object?> get props => [walletBalance, games];
}
