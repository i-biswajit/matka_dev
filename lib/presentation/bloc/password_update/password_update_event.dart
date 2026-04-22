part of 'password_update_bloc.dart';

abstract class PasswordUpdateEvent extends Equatable {
  const PasswordUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Submit password update
class PasswordUpdateRequested extends PasswordUpdateEvent {
  final String newPassword;

  const PasswordUpdateRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}
