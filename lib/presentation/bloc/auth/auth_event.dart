part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupSubmitted extends AuthEvent {}

class LoginSubmitted extends AuthEvent {}

class SendOtp extends AuthEvent {}
