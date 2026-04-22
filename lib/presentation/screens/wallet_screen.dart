import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matka_dev/data/models/wallet_transaction_model.dart';
import 'package:matka_dev/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';
import 'package:matka_dev/presentation/screens/add_funds_screen.dart';
import 'package:matka_dev/presentation/screens/withdraw_funds_screen.dart';
import '../../core/constants/colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 Refresh profile + balance
    context.read<DashboardBloc>().add(LoadDashboard());
    // 🔥 Load wallet transactions
    context.read<WalletBloc>().add(LoadWallet());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Wallet Statement"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletInitial || state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.red, fontSize: w * 0.04),
              ),
            );
          }

          if (state is WalletLoaded) {
            return RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: () async {
                context.read<DashboardBloc>().add(LoadDashboard());
                context.read<WalletBloc>().add(LoadWallet());
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04, vertical: h * 0.02),
                child: Column(
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.05),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimaryColor, Color(0xFF4A6CF7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.wallet,
                              color: Colors.white, size: w * 0.12),
                          SizedBox(height: h * 0.01),
                          BlocBuilder<DashboardBloc, DashboardState>(
                            builder: (context, dashState) {
                              if (dashState is DashboardLoaded) {
                                return BlocBuilder<WalletBloc, WalletState>(
                                  builder: (context, state) {
                                    if (state is WalletLoaded) {
                                      return Text(
                                        "₹${state.balance}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: w * 0.085,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                    return Text(
                                      "₹0",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: w * 0.085,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                );
                              }
                              return const Text("₹ 0",
                                  style: TextStyle(color: Colors.white));
                            },
                          ),
                          SizedBox(height: h * 0.005),
                          Text(
                            "Available Balance",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: w * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_downward),
                            label: const Text("Withdraw"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding:
                                  EdgeInsets.symmetric(vertical: h * 0.018),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<WalletBloc>(),
                                    child: const WithdrawFundsScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: w * 0.04),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text(
                              "Add Funds",
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: kPrimaryColor,
                              padding:
                                  EdgeInsets.symmetric(vertical: h * 0.018),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<WalletBloc>(),
                                    child: const AddFundsScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: h * 0.025),

                    // Transaction header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "TRANSACTIONS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.045),
                      ),
                    ),
                    SizedBox(height: h * 0.01),

                    // Transaction List
                    Expanded(
                      child: state.transactions.isEmpty
                          ? Center(
                              child: Text(
                                "No transactions yet",
                                style: TextStyle(fontSize: w * 0.04),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.transactions.length,
                              itemBuilder: (context, index) {
                                final tx = state.transactions[index];
                                return _transactionClickable(tx, w, h);
                              },
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
    );
  }

  Widget _transactionClickable(WalletTransactionModel tx, double w, double h) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showTransactionDetails(tx), // 👈 tap action
      child: _transactionItem(tx, w, h),
    );
  }

  void _showTransactionDetails(WalletTransactionModel tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) {
        final h = MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Status bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _statusColor(tx.status),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              _detailRow("Type", tx.type.toUpperCase()),
              _detailRow("Amount", "₹ ${tx.amount}"),
              _detailRow("Balance After", "₹ ${tx.balance}"),
              _detailRow("Status", tx.status.toUpperCase(),
                  color: _statusColor(tx.status)),
              _detailRow("Date", tx.date.split('T').first),
              _detailRow("Description", tx.description),
              const SizedBox(height: 20),
              // Close button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _statusColor(tx.status),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(WalletTransactionModel tx, double w, double h) {
    final isCredit = tx.type.toLowerCase() == 'credit';
    final statusColor = _statusColor(tx.status);

    final double amount = double.tryParse(tx.amount.replaceAll(',', '')) ?? 0;
    final bool isBigAmount = isCredit && amount >= 10000;

    return Container(
      margin: EdgeInsets.symmetric(vertical: h * 0.006),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isBigAmount
                ? Colors.green.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
            blurRadius: isBigAmount ? 18 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT STATUS STRIP
          Container(
            width: w * 0.015,
            height: h * 0.12,
            decoration: BoxDecoration(
              color: isCredit ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(width: w * 0.03),

          /// ICON
          Container(
            width: w * 0.12,
            height: w * 0.12,
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : Colors.red).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: w * 0.06,
            ),
          ),

          SizedBox(width: w * 0.04),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Credit / Debit label
                Row(
                  children: [
                    Icon(
                      isCredit ? Icons.call_received : Icons.call_made,
                      size: 14,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: w * 0.01),
                    Text(
                      isCredit ? "Credit" : "Debit",
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.004),

                /// Description
                Text(
                  tx.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: w * 0.04,
                  ),
                ),

                SizedBox(height: h * 0.002),

                /// Date
                Text(
                  tx.date.split('T').first,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: w * 0.03,
                  ),
                ),

                SizedBox(height: h * 0.006),

                /// Status row
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: w * 0.015),
                    Text(
                      tx.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                /// BIG CREDIT TAG
                if (isBigAmount) ...[
                  SizedBox(height: h * 0.006),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "BIG CREDIT 🎉",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          /// AMOUNT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isCredit ? '+' : '-'} ₹ ${tx.amount}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                  fontSize: w * 0.045,
                ),
              ),
              SizedBox(height: h * 0.004),
              Text(
                "₹ ${tx.balance}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: w * 0.03,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
