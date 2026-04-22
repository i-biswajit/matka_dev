import 'package:matka_dev/data/models/wallet_transaction_model.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;
  final double minWithdraw;
  final double maxWithdraw;
  final List<WalletTransactionModel> transactions;

  WalletLoaded({
    required this.balance,
    required this.minWithdraw,
    required this.maxWithdraw,
    required this.transactions,
  });
}

class WalletUpiInProgress extends WalletState {}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

class WalletPaymentProcessing extends WalletState {}

class WalletPaymentSuccess extends WalletState {
  final String transactionId;
  WalletPaymentSuccess(this.transactionId);
}

class WalletPaymentPending extends WalletState {
  final String message;
  WalletPaymentPending({required this.message});
}

class WalletPaymentFailure extends WalletState {
  final String message;
  WalletPaymentFailure({required this.message});
}

class BankDetailsLoading extends WalletState {}

class BankDetailsSuccess extends WalletState {
  final String message;
  BankDetailsSuccess(this.message);
}

class BankDetailsFailure extends WalletState {
  final String error;
  BankDetailsFailure(this.error);
}

class BankDetailsLoaded extends WalletState {
  final Map<String, dynamic> bankData;
  BankDetailsLoaded(this.bankData);
}

class WithdrawSuccess extends WalletState {
  final String message;
  WithdrawSuccess(this.message);
}
