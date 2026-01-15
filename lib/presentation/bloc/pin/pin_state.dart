abstract class PinState {}

class PinInitial extends PinState {}

class PinLoading extends PinState {}

class PinSuccess extends PinState {}

class PinFailure extends PinState {
  final String message;
  PinFailure(this.message);
}
