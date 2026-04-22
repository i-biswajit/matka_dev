import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/presentation/bloc/add_funds_history/add_funds_history_bloc.dart';

class AddFundHistoryScreen extends StatelessWidget {
  const AddFundHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    context.read<AddFundHistoryBloc>().add(FetchAddFundHistory());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Add Fund History"),
      ),
      body: BlocBuilder<AddFundHistoryBloc, AddFundHistoryState>(
        builder: (context, state) {
          if (state is AddFundHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddFundHistoryError) {
            return Center(child: Text(state.message));
          }

          if (state is AddFundHistoryLoaded) {
            if (state.history.isEmpty) {
              return _emptyFundsHistory(context);
            }

            return RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: () async {
                context.read<AddFundHistoryBloc>().add(FetchAddFundHistory());
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.015,
                ),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final item = state.history[index];

                  final Color statusColor = item.status == "approved"
                      ? Colors.green
                      : item.status == "reject"
                          ? Colors.red
                          : Colors.orange;

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 350 + (index * 80)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showFundsDetails(context, item),
                      child: Container(
                        margin: EdgeInsets.only(bottom: h * 0.010),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            /// Left status bar
                            Container(
                              width: w * 0.015,
                              height: h * 0.13,
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                            ),

                            SizedBox(width: w * 0.03),

                            /// Main content
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: h * 0.018,
                                  horizontal: w * 0.02,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Amount
                                    Text(
                                      "₹ ${item.amount}",
                                      style: TextStyle(
                                        fontSize: w * 0.045,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    SizedBox(height: h * 0.006),

                                    /// Date
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a')
                                          .format(item.createdAt),
                                      style: TextStyle(
                                        fontSize: w * 0.032,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    /// Metadata
                                    if (item.metadata.isNotEmpty) ...[
                                      SizedBox(height: h * 0.004),
                                      Text(
                                        item.metadata,
                                        style: TextStyle(
                                          fontSize: w * 0.033,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],

                                    /// Reject comment
                                    if (item.status == "reject" &&
                                        item.comment != null &&
                                        item.comment!.isNotEmpty) ...[
                                      SizedBox(height: h * 0.006),
                                      Text(
                                        item.comment!,
                                        style: TextStyle(
                                          fontSize: w * 0.033,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            /// Status badge
                            Padding(
                              padding: EdgeInsets.only(right: w * 0.03),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.03,
                                  vertical: h * 0.008,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formatStatus(item.status),
                                  style: TextStyle(
                                    fontSize: w * 0.032,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showFundsDetails(BuildContext context, item) {
    final Color statusColor = item.status == "approved"
        ? Colors.green
        : item.status == "reject"
            ? Colors.red
            : Colors.orange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final h = MediaQuery.of(context).size.height;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Details
              _detailRow("Amount", "₹ ${item.amount}"),
              _detailRow(
                "Date",
                DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt),
              ),
              if (item.metadata.isNotEmpty) _detailRow("UTR", item.metadata),
              _detailRow(
                "Status",
                formatStatus(item.status),
                color: statusColor,
              ),
              if (item.status == "reject" &&
                  item.comment != null &&
                  item.comment!.isNotEmpty)
                _detailRow("Comment", item.comment!, color: Colors.red),

              const SizedBox(height: 20),

              // Close button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _emptyFundsHistory(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Add Funds History Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You haven’t added any funds yet.\nStart playing and try your luck!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 25),

            /// 🎯 PLAY NOW BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // OR navigate to your Market screen:
                  Navigator.pushNamed(context, '/add_funds');
                },
                child: const Text(
                  "ADD FUNDS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatStatus(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'reject':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }
}
