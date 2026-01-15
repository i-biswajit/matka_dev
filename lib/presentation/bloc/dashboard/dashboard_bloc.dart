import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc()
      : super(DashboardLoaded(
          walletBalance: 5,
          games: const [
            "KARNATAKA DAY",
            "SRIDEVI MORNING",
            "MILAN MORNING",
            "KALYAN MORNING",
          ],
        )) {
    on<LoadDashboard>((event, emit) {
      // static for now
      emit(state);
    });
  }
}
