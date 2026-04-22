part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignupSuccess extends AuthState {
  final String message;
  SignupSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LoginSuccess extends AuthState {
  final String message;
  LoginSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
