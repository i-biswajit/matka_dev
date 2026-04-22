part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// 🔹 Initial / Logged out
class DashboardInitial extends DashboardState {}

/// 🔹 Loading (future API use)
class DashboardLoading extends DashboardState {}

/// 🔹 Loaded state (auto-login success)
class DashboardLoaded extends DashboardState {
  final String userName;
  final String mobile;
  final List<GameModel> games;
  final bool isRefreshing;

  const DashboardLoaded({
    required this.userName,
    required this.mobile,
    required this.games,
    this.isRefreshing = false,
  });

  DashboardLoaded copyWith({
    List<GameModel>? games,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      userName: userName,
      mobile: mobile,
      games: games ?? this.games,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [userName, mobile, games, isRefreshing];
}

/// 🔹 Error state (future use)
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
