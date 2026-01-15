abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoaded extends WalletState {
  final int points;
  final List<Map<String, dynamic>> transactions;

  WalletLoaded({
    required this.points,
    required this.transactions,
  });
}
