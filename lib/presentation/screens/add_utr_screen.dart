import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';

class AddUtrScreen extends StatefulWidget {
  final double? amount;
  const AddUtrScreen({super.key, this.amount});

  @override
  State<AddUtrScreen> createState() => _AddUtrScreenState();
}

class _AddUtrScreenState extends State<AddUtrScreen> {
  final utrController = TextEditingController();
  final amountController = TextEditingController();
  bool get isAmountLocked => widget.amount != null;

  @override
  void initState() {
    super.initState();
    if (widget.amount != null) {
      amountController.text = widget.amount!.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        // ✅ On success → go to Dashboard
        if (state is WalletPaymentPending) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/dashboard',
            (route) => false,
          );
        }

        // ❌ On error → show message
        if (state is WalletError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is WalletPaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: kPrimaryColor,
            title: const Text("Submit Payment"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )),
        body: Padding(
          padding: EdgeInsets.all(w * 0.04),
          child: Column(
            children: [
              /// 💳 Payment Card
              Container(
                padding: EdgeInsets.all(w * 0.045),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(w * 0.045),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: w * 0.03,
                      offset: Offset(0, h * 0.006),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 💰 Amount Label
                    Text(
                      "Amount Paid",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: w * 0.038,
                      ),
                    ),
                    SizedBox(height: h * 0.01),

                    /// 💰 Amount Field
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      enabled: !isAmountLocked,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          color: kPrimaryColor,
                          size: w * 0.055,
                        ),
                        hintText: "Enter amount",
                        filled: true,
                        fillColor: isAmountLocked
                            ? Colors.grey.shade200
                            : kTextFieldBg,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: h * 0.018,
                          horizontal: w * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.035),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    if (isAmountLocked) ...[
                      SizedBox(height: h * 0.006),
                      Text(
                        "Amount is pre-filled from your request",
                        style: TextStyle(
                          fontSize: w * 0.03,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    SizedBox(height: h * 0.022),

                    /// 🔐 UTR Label
                    Text(
                      "UTR / Transaction ID",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: w * 0.038,
                      ),
                    ),
                    SizedBox(height: h * 0.01),

                    /// 🔐 UTR Field
                    TextField(
                      controller: utrController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.receipt_long,
                          color: kPrimaryColor,
                          size: w * 0.055,
                        ),
                        hintText: "Enter UTR number",
                        filled: true,
                        fillColor: kTextFieldBg,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: h * 0.018,
                          horizontal: w * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.035),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.006),
                    Text(
                      "Enter the UTR from your payment app",
                      style: TextStyle(
                        fontSize: w * 0.03,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// 🚀 Submit Button
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: EdgeInsets.symmetric(vertical: h * 0.022),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.045),
                        ),
                        elevation: 4,
                      ),
                      onPressed: state is WalletLoading
                          ? null
                          : () {
                              final amount = double.tryParse(
                                      amountController.text.trim()) ??
                                  0;

                              if (amount < 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Enter valid amount")),
                                );
                                return;
                              }
                              if (utrController.text.length < 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid UTR")),
                                );
                                return;
                              }

                              context.read<WalletBloc>().add(
                                    SubmitUtrRequested(
                                      amount: amount,
                                      utr: utrController.text.trim(),
                                    ),
                                  );
                            },
                      child: state is WalletLoading
                          ? SizedBox(
                              height: w * 0.055,
                              width: w * 0.055,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Submit Payment",
                              style: TextStyle(
                                fontSize: w * 0.042,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
