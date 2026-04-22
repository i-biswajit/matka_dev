part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Load dashboard after auto-login
class LoadDashboard extends DashboardEvent {}

/// 🔹 Logout event
class DashboardLogoutRequested extends DashboardEvent {}
