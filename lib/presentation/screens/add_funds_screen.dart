// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matka_dev/core/utils/wallet_qr.dart';
import 'package:matka_dev/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:matka_dev/presentation/screens/add_utr_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_india/upi_india.dart';
import '../../core/constants/colors.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final amountController = TextEditingController();
  double minDeposit = 0;
  double maxDeposit = 0;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDepositLimits();
  }

  Future<void> _loadDepositLimits() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      minDeposit = double.tryParse(prefs.getInt('min_deposit').toString()) ?? 0;
      maxDeposit = double.tryParse(prefs.getInt('max_deposit').toString()) ?? 0;
    });
  }

  Future<void> _refreshWallet() async {
    context.read<WalletBloc>().add(LoadWallet());
  }

  Future<void> _showUpiAppChooser(double amount) async {
    final upiIndia = UpiIndia();
    final apps = await upiIndia.getAllUpiApps();

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No UPI apps installed")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // IMPORTANT
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;

        // 🔥 Responsive columns
        int crossAxisCount = 4;
        if (width < 360) {
          crossAxisCount = 3;
        } else if (width > 600) {
          crossAxisCount = 6; // tablet
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const Text(
                  "Choose UPI App",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 🔥 Responsive grid with max height
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: GridView.builder(
                    itemCount: apps.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final app = apps[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<WalletBloc>().add(
                                AddFundsUpiRequested(
                                  amount: amount,
                                  app: app,
                                ),
                              );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.memory(
                              app.icon,
                              height: 44,
                              width: 44,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              app.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    List<num> quickAmounts = [];

    if (minDeposit > 0 && maxDeposit > 0) {
      quickAmounts = {
        minDeposit,
        300,
        500,
        1000,
        2000,
        5000,
      }.where((amount) => amount >= minDeposit && amount <= maxDeposit).toList()
        ..sort(); // optional: keeps order ascending
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Add Funds"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletPaymentProcessing) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }
          if (state is WalletPaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment Successful 🎉"),
                backgroundColor: Colors.green,
              ),
            );

            // Refresh Wallet
            context.read<WalletBloc>().add(LoadWallet());

            // Go back to Dashboard
            Navigator.popUntil(context, (route) => route.isFirst);
            context.read<DashboardBloc>().add(LoadDashboard());
          }
          if (state is WalletPaymentPending) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is WalletPaymentFailure) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading || state is WalletInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletUpiInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletLoaded) {
              return RefreshIndicator(
                onRefresh: _refreshWallet,
                color: kPrimaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.05, vertical: h * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 💎 Current Balance Card
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
                              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.25),
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
                                    "Current Balance",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  BlocBuilder<WalletBloc, WalletState>(
                                    builder: (context, state) {
                                      if (state is WalletLoaded) {
                                        return Text(
                                          "₹${state.balance}",
                                          style: TextStyle(
                                            fontSize: w * 0.085,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }

                                      if (state is WalletLoading) {
                                        return Text(
                                          "₹...",
                                          style: TextStyle(
                                            fontSize: w * 0.085,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }

                                      return Text(
                                        "₹0",
                                        style: TextStyle(
                                          fontSize: w * 0.085,
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

                      SizedBox(height: h * 0.03),

                      // ⚠️ Notice
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(w * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Minimum Deposit: ₹${minDeposit.toInt()}\nIf payment does not reflect, refresh wallet or contact admin.",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.03),

                      // 💰 Enter Amounts
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.currency_rupee),
                          hintText: "Enter amount",
                          helperText: "Minimum ₹${minDeposit.toInt()}",
                          filled: true,
                          fillColor: kTextFieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      // Quick Amount Buttons
                      Wrap(
                        spacing: 10,
                        children: quickAmounts.map((amt) {
                          return ChoiceChip(
                            label: Text("₹${amt.toInt()}"),
                            selected:
                                amountController.text == amt.toInt().toString(),
                            selectedColor: kPrimaryColor,
                            labelStyle: TextStyle(
                              color: amountController.text ==
                                      amt.toInt().toString()
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onSelected: (_) {
                              setState(() {
                                amountController.text = amt.toInt().toString();
                              });
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: h * 0.03),

                      // ✅ Add Funds Button
                      SizedBox(
                        width: double.infinity,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1, end: 1.04),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.flash_on),
                            label: _isProcessing
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Add Funds"),
                            onPressed: _isProcessing
                                ? null
                                : () async {
                                    final amount = double.tryParse(
                                            amountController.text) ??
                                        0;
                                    if (amount < minDeposit) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Minimum deposit is ₹${minDeposit.toInt()}")),
                                      );
                                      return;
                                    }
                                    setState(() => _isProcessing = true);
                                    await _showUpiAppChooser(amount);
                                    setState(() => _isProcessing = false);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: h * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.qr_code),
                          label: const Text("Pay via QR"),
                          onPressed: () {
                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            if (amount < minDeposit) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Minimum Deposit: ₹${minDeposit.toInt()}\nMaximum Deposit: ₹${maxDeposit.toInt()}")),
                              );
                              return;
                            }
                            showQrPaymentDialog(context, amount);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                            padding: EdgeInsets.symmetric(vertical: h * 0.02),
                            side: const BorderSide(
                                color: kPrimaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddUtrScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: h * 0.02),
                            side: const BorderSide(
                                color: kPrimaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Add UTR / Transaction ID",
                            style:
                                TextStyle(fontSize: 16, color: kPrimaryColor),
                          ),
                        ),
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
}
