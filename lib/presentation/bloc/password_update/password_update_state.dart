part of 'password_update_bloc.dart';

abstract class PasswordUpdateState extends Equatable {
  const PasswordUpdateState();

  @override
  List<Object?> get props => [];
}

class PasswordInitial extends PasswordUpdateState {}

class PasswordLoading extends PasswordUpdateState {}

class PasswordSuccess extends PasswordUpdateState {
  final String message;

  const PasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordFailure extends PasswordUpdateState {
  final String error;

  const PasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
