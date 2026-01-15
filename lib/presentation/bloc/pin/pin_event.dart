abstract class PinEvent {}

class PinSubmitted extends PinEvent {
  final String pin;
  PinSubmitted(this.pin);
}
