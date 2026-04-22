import 'package:upi_india/upi_app.dart';

abstract class WalletEvent {}

class LoadWallet extends WalletEvent {}

class AddFundsUpiRequested extends WalletEvent {
  final double amount;
  final UpiApp app;
  AddFundsUpiRequested({
    required this.amount,
    required this.app,
  });
}

class UpdateBankDetails extends WalletEvent {
  final String? bankAcName;
  final String? bankAcNumber;
  final String? bankIfsc;
  final String? bankPostalCode;
  final String? bankBranchAddress;

  UpdateBankDetails({
    this.bankAcName,
    this.bankAcNumber,
    this.bankIfsc,
    this.bankPostalCode,
    this.bankBranchAddress,
  });
}

class LoadBankDetails extends WalletEvent {}

class LoadUpiDetails extends WalletEvent {
  final String app;
  LoadUpiDetails(this.app);
}

class UpdateUpiDetails extends WalletEvent {
  final String app;
  final String number;

  UpdateUpiDetails({required this.app, required this.number});
}

class WithdrawRequested extends WalletEvent {
  final double amount;
  final String method;

  WithdrawRequested({required this.amount, required this.method});
}

class SubmitUtrRequested extends WalletEvent {
  final double amount;
  final String utr;

  SubmitUtrRequested({required this.amount, required this.utr});
}
