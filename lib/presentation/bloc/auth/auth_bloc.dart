import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignupSubmitted>((event, emit) {
      emit(AuthSuccess(message: "Signup clicked!"));
    });
    on<LoginSubmitted>((event, emit) {
      emit(AuthSuccess(message: "Login clicked!"));
    });
    on<SendOtp>((event, emit) {
      emit(AuthSuccess(message: "OTP sent!"));
    });
  }
}
