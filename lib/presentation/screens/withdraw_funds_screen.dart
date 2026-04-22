import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matka_dev/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:matka_dev/presentation/screens/bank_details_screen.dart';
import 'package:matka_dev/presentation/screens/upi_details_screen.dart';
import '../../core/constants/colors.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final amountController = TextEditingController();
  String? selectedMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "label": "Bank Transfer",
      "value": "bank transfer",
      "icon": "assets/images/bank.png",
    },
    {
      "label": "PhonePe",
      "value": "phonepe",
      "icon": "assets/images/phonepe.png",
    },
    {
      "label": "Google Pay",
      "value": "gpay",
      "icon": "assets/images/gpay.png",
    },
    {
      "label": "PayTM",
      "value": "paytm",
      "icon": "assets/images/paytm.png",
    },
  ];

  Future<void> _refreshWallet() async {
    context.read<WalletBloc>().add(LoadWallet());
  }

  void _onWithdrawPressed() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      _showSnack("Enter valid amount");
      return;
    }

    if (selectedMethod == null) {
      _showSnack("Select payment method");
      return;
    }

    context.read<WalletBloc>().add(
          WithdrawRequested(
            amount: amount,
            method: selectedMethod!,
          ),
        );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Withdraw Funds"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<WalletBloc>().add(LoadWallet()); // 🔄 refresh balance
            // 🔙 Navigate back to Dashboard
            Navigator.popUntil(context, (route) => route.isFirst);
            context.read<DashboardBloc>().add(LoadDashboard());
          }
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading || state is WalletInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletLoaded) {
              return RefreshIndicator(
                color: kPrimaryColor,
                onRefresh: _refreshWallet,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.05, vertical: h * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Current Balance
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.9, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(w * 0.05),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf7971e), Color(0xFFffd200)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Available Balance",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  BlocBuilder<WalletBloc, WalletState>(
                                    builder: (context, state) {
                                      if (state is WalletLoaded) {
                                        return Text(
                                          "₹${state.balance}",
                                          style: TextStyle(
                                            fontSize: w * 0.08,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }

                                      if (state is WalletLoading) {
                                        return Text(
                                          "₹...",
                                          style: TextStyle(
                                            fontSize: w * 0.08,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }

                                      return Text(
                                        "₹0",
                                        style: TextStyle(
                                          fontSize: w * 0.08,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const Icon(FontAwesomeIcons.wallet,
                                  size: 40, color: Colors.white),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Enter Amount
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.currency_rupee),
                          hintText: "Enter withdrawal amount",
                          helperText: "Minimum withdrawal as per policy",
                          filled: true,
                          fillColor: kTextFieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Payment Method",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: paymentMethods.map((method) {
                          final bool isSelected =
                              selectedMethod == method["value"];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMethod = method["value"];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kPrimaryColor.withOpacity(0.15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(method["icon"], height: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    method["label"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? kPrimaryColor
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_outline),
                          label: const Text("Withdraw Funds"),
                          onPressed: _onWithdrawPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.grey),
                          SizedBox(width: 6),
                          Text(
                            "Withdrawals are processed within 24 hours",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Payment Setup",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Payment Method Buttons
                      Column(
                        children: [
                          _paymentMethodButton(context, "Bank Details", null,
                              Colors.blue, const BankDetailsScreen(), h),
                          _paymentMethodButton(
                              context,
                              "PhonePe",
                              null,
                              Colors.purple,
                              const UpiDetailsScreen("PhonePe"),
                              h),
                          _paymentMethodButton(context, "Google Pay", null,
                              Colors.green, const UpiDetailsScreen("GPay"), h),
                          _paymentMethodButton(
                              context,
                              "PayTM",
                              null,
                              Colors.blueAccent,
                              const UpiDetailsScreen("PayTM"),
                              h),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _paymentMethodButton(BuildContext context, String label,
      IconData? icon, Color color, Widget screen, double h) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<WalletBloc>(),
              child: screen,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            icon != null
                ? Icon(icon, color: color, size: 30)
                : Image.asset(
                    _getPaymentIcon(label),
                    height: h * 0.045,
                  ),
            const SizedBox(width: 12),
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

String _getPaymentIcon(String label) {
  switch (label) {
    case "PhonePe":
      return "assets/images/phonepe.png";
    case "Google Pay":
      return "assets/images/gpay.png";
    case "PayTM":
      return "assets/images/paytm.png";
    case "Bank Details":
      return "assets/images/bank.png";
    default:
      return "assets/images/bank.png";
  }
}
