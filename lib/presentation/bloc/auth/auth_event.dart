part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupSubmitted extends AuthEvent {
  final String name;
  final String mobile;
  final String password;

  SignupSubmitted({
    required this.name,
    required this.mobile,
    required this.password,
  });

  @override
  List<Object?> get props => [name, mobile, password];
}

class LoginSubmitted extends AuthEvent {
  final String mobile;
  final String password;

  LoginSubmitted({
    required this.mobile,
    required this.password,
  });

  @override
  List<Object?> get props => [mobile, password];
}

class LogoutSubmitted extends AuthEvent {}

class SendOtp extends AuthEvent {}
