import 'package:flutter_bloc/flutter_bloc.dart';
import 'pin_event.dart';
import 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  PinBloc() : super(PinInitial()) {
    on<PinSubmitted>((event, emit) async {
      emit(PinLoading());
      await Future.delayed(const Duration(seconds: 1));

      if (event.pin == '1234') {
        emit(PinSuccess());
      } else {
        emit(PinFailure('Invalid PIN'));
      }
    });
  }
}
