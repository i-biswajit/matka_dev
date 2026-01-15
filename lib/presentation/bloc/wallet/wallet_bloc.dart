import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<LoadWallet>((event, emit) {
      emit(
        WalletLoaded(
          points: 5,
          transactions: [
            {
              "title": "Welcome Bonus",
              "date": "2025-12-18 22:47:38",
              "points": 5,
              "success": true,
            }
          ],
        ),
      );
    });
  }
}
