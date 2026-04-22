import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignupSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await authRepository.signup(
          name: event.name,
          mobile: event.mobile,
          password: event.password,
        );
        emit(SignupSuccess(message: message)); // ✅
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await authRepository.login(
          mobile: event.mobile,
          password: event.password,
        );
        emit(LoginSuccess(message: message)); // ✅
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<LogoutSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logout();
        await AuthStorage.logout();
        emit(AuthInitial());
      } catch (_) {
        await AuthStorage.logout();
        emit(AuthInitial());
      }
    });

    on<SendOtp>((event, emit) {
      emit(LoginSuccess(message: "OTP sent!"));
    });
  }
}
