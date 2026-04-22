import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/data/repositories/wallet_repository.dart';
import 'package:upi_india/upi_india.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<LoadWallet>((event, emit) async {
      emit(WalletLoading());

      try {
        final balanceString = await repository.getLocalBalance();
        final transactions = await repository.fetchWalletHistory();

        final minWithdrawString = await AuthStorage.getMinWithdraw();
        final maxWithdrawString = await AuthStorage.getMaxWithdraw();

        emit(WalletLoaded(
          balance: double.tryParse(balanceString) ?? 0,
          minWithdraw: double.tryParse(minWithdrawString ?? "0") ?? 0,
          maxWithdraw: double.tryParse(maxWithdrawString ?? "0") ?? 0,
          transactions: transactions,
        ));
      } catch (e) {
        emit(WalletError(e.toString()));
      }
    });

    on<AddFundsUpiRequested>((event, emit) async {
      emit(WalletUpiInProgress());

      try {
        final upiIndia = UpiIndia();
        final merchantId = await AuthStorage.getMerchantId();
        if (merchantId == null || merchantId.isEmpty) {
          emit(WalletPaymentFailure(
              message: "Payment is temporarily unavailable"));
          return;
        }

        final response = await upiIndia.startTransaction(
          app: event.app,
          receiverUpiId: merchantId,
          receiverName: "Matka Dev",
          transactionRefId: DateTime.now().millisecondsSinceEpoch.toString(),
          transactionNote: "Add Funds",
          amount: event.amount,
        );

        if (response.status == UpiPaymentStatus.SUCCESS) {
          final ref = 'status:success'
              '| txn_id:${response.transactionId}';

          await repository.addFund(
            amount: event.amount.toInt(),
            ref: ref,
          );
          final currentBalanceStr = await AuthStorage.getUserBalance();
          final currentBalance = double.tryParse(currentBalanceStr ?? "0") ?? 0;
          final newBalance = currentBalance + event.amount;
          await AuthStorage.setUserBalance(newBalance.toString());
          emit(WalletPaymentSuccess("Funds added successfully"));
          emit(WalletLoaded(
            balance: newBalance,
            minWithdraw:
                double.tryParse(await AuthStorage.getMinWithdraw() ?? "0") ?? 0,
            maxWithdraw:
                double.tryParse(await AuthStorage.getMaxWithdraw() ?? "0") ?? 0,
            transactions: await repository.fetchWalletHistory(),
          ));
        } else if (response.status == UpiPaymentStatus.SUBMITTED) {
          emit(WalletPaymentFailure(message: "Payment pending"));
        } else {
          emit(WalletPaymentFailure(message: "Payment failed or cancelled"));
        }
      } catch (e) {
        emit(WalletPaymentFailure(message: e.toString()));
      }
      add(LoadWallet());
    });

    on<UpdateBankDetails>((event, emit) async {
      emit(BankDetailsLoading());

      try {
        final response = await repository.updateBankDetails(
          name: event.bankAcName,
          accNumber: event.bankAcNumber,
          ifsc: event.bankIfsc,
          postalCode: event.bankPostalCode,
          branchAddress: event.bankBranchAddress,
        );

        if (response['status'] == true) {
          emit(BankDetailsSuccess(response['message'] ?? "Updated"));
        } else {
          emit(BankDetailsFailure(response['message'] ?? "Update failed"));
        }
      } catch (e) {
        emit(BankDetailsFailure("Something went wrong"));
      }
      add(LoadWallet());
    });

    on<LoadBankDetails>((event, emit) async {
      emit(BankDetailsLoading());

      try {
        final response = await repository.fetchBankDetails();

        if (response['status'] == true) {
          emit(BankDetailsLoaded(response['data']));
        } else {
          emit(BankDetailsFailure(response['message'] ?? "No bank data"));
        }
      } catch (e) {
        emit(BankDetailsFailure("Failed to load bank details"));
      }
      add(LoadWallet());
    });

    on<LoadUpiDetails>((event, emit) async {
      emit(BankDetailsLoading());

      try {
        final res = await repository.fetchBankDetails();

        if (res['status'] == true) {
          emit(BankDetailsLoaded(res['data']));
        } else {
          emit(BankDetailsFailure("No UPI data"));
        }
      } catch (_) {
        emit(BankDetailsFailure("Failed to load UPI details"));
      }
      add(LoadWallet());
    });

    on<UpdateUpiDetails>((event, emit) async {
      emit(BankDetailsLoading());

      try {
        final res = await repository.updateUpiDetails(event.app, event.number);

        if (res['status'] == true) {
          emit(BankDetailsSuccess(res['message']));
        } else {
          emit(BankDetailsFailure(res['message']));
        }
      } catch (_) {
        emit(BankDetailsFailure("UPI update failed"));
      }
      add(LoadWallet());
    });

    on<WithdrawRequested>((event, emit) async {
      if (state is! WalletLoaded) return;

      final currentState = state as WalletLoaded;
      final enteredAmount = event.amount.toDouble();

      if (enteredAmount < currentState.minWithdraw) {
        emit(WalletError("Minimum withdrawal is ₹${currentState.minWithdraw}"));
        add(LoadWallet());
        return;
      }

      if (enteredAmount > currentState.maxWithdraw) {
        emit(WalletError("Maximum withdrawal is ₹${currentState.maxWithdraw}"));
        add(LoadWallet());
        return;
      }

      if (enteredAmount > currentState.balance) {
        emit(WalletError("Insufficient balance"));
        add(LoadWallet());
        return;
      }

      try {
        await repository.withdraw(
          amount: event.amount,
          method: event.method,
        );

        final newBalance = currentState.balance - enteredAmount;
        await AuthStorage.setUserBalance(newBalance.toString());

        emit(WithdrawSuccess("Withdrawal request submitted"));
        emit(WalletLoaded(
          balance: newBalance,
          minWithdraw: currentState.minWithdraw,
          maxWithdraw: currentState.maxWithdraw,
          transactions: await repository.fetchWalletHistory(),
        ));
        add(LoadWallet());
      } catch (e) {
        emit(WalletError(e.toString()));
      }
    });

    on<SubmitUtrRequested>((event, emit) async {
      emit(WalletPaymentProcessing());

      try {
        final response = await repository.utrSubmitRequest(
          amount: event.amount.toInt(),
          ref: event.utr,
        );

        if (response) {
          emit(WalletPaymentPending(
            message: "Payment submitted. Verification pending.",
          ));
        } else {
          emit(WalletPaymentFailure(
            message: "Request failed",
          ));
        }
      } catch (e) {
        emit(WalletPaymentFailure(message: e.toString()));
      }
      add(LoadWallet());
    });
  }
}
