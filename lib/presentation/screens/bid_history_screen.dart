import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/core/utils/string_extension.dart';
import 'package:matka_dev/presentation/bloc/bid_history/bid_history_bloc.dart';

class BidHistoryScreen extends StatelessWidget {
  const BidHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (_) => context.read<BidHistoryBloc>()..add(LoadBidHistory()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text('Bid History'),
        ),
        body: BlocBuilder<BidHistoryBloc, BidHistoryState>(
          builder: (context, state) {
            if (state is BidHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BidHistoryError) {
              return Center(child: Text(state.message));
            }

            if (state is BidHistoryLoaded) {
              if (state.bids.isEmpty) {
                return _emptyBidHistory(context);
              }
              return RefreshIndicator(
                color: kPrimaryColor,
                onRefresh: () async {
                  context.read<BidHistoryBloc>().add(LoadBidHistory());
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.015,
                  ),
                  itemCount: state.bids.length,
                  itemBuilder: (context, i) {
                    final bid = state.bids[i];
                    final status = bid.isWin;

                    final isWin = status == 1;
                    final isLoss = status == 2;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 350 + (i * 80)),
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
                        onTap: () => _showBidDetails(context, bid),
                        child: Container(
                          margin: EdgeInsets.only(bottom: h * 0.015),
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
                              // Left status bar
                              Container(
                                width: w * 0.015,
                                height: h * 0.12,
                                decoration: BoxDecoration(
                                  color: isWin
                                      ? Colors.green
                                      : isLoss
                                          ? Colors.red
                                          : Colors.orange,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  ),
                                ),
                              ),

                              SizedBox(width: w * 0.03),

                              // Main content
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: h * 0.018,
                                    horizontal: w * 0.02,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Digit ${bid.digit}  •  ₹${bid.amount}',
                                        style: TextStyle(
                                          fontSize: w * 0.045,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: h * 0.006),
                                      Text(
                                        '${bid.date} • ${bid.bidTime.toUpperCase()} • ${bid.gameType.toTitleCase()}',
                                        style: TextStyle(
                                          fontSize: w * 0.032,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Win / Loss badge
                              Padding(
                                padding: EdgeInsets.only(right: w * 0.03),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.03,
                                    vertical: h * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isWin
                                        ? Colors.green.withOpacity(0.15)
                                        : isLoss
                                            ? Colors.red.withOpacity(0.15)
                                            : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isWin
                                        ? 'WIN ₹${bid.winAmount}'
                                        : isLoss
                                            ? 'LOSS'
                                            : 'PENDING',
                                    style: TextStyle(
                                      fontSize: w * 0.032,
                                      fontWeight: FontWeight.bold,
                                      color: isWin
                                          ? Colors.green
                                          : isLoss
                                              ? Colors.red
                                              : Colors.orange,
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
      ),
    );
  }

  void _showBidDetails(BuildContext context, bid) {
    final status = bid.isWin;

    final isWin = status == 1;
    final isLoss = status == 2;

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
                  color: isWin
                      ? Colors.green
                      : isLoss
                          ? Colors.red
                          : Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              _detailRow("Game", bid.game.name.toUpperCase()),
              _detailRow(
                  "Game Type", bid.gameType.replaceAll('_', ' ').toUpperCase()),
              _detailRow("Digit", bid.digit.toString()),
              _detailRow("Bid Amount", "₹ ${bid.amount}"),
              _detailRow("Bid Time", bid.bidTime.toUpperCase()),
              _detailRow("Date", bid.date),
              _detailRow(
                "Result",
                isWin
                    ? "WIN"
                    : isLoss
                        ? "LOSS"
                        : "PENDING",
                color: isWin
                    ? Colors.green
                    : isLoss
                        ? Colors.red
                        : Colors.orange,
              ),
              if (isWin)
                _detailRow(
                  "Win Amount",
                  "₹ ${bid.winAmount}",
                  color: Colors.green,
                ),
              const SizedBox(height: 20),
              // Close button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWin
                        ? Colors.green
                        : isLoss
                            ? Colors.red
                            : Colors.orange,
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

  Widget _emptyBidHistory(BuildContext context) {
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
              "No Bid History Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You haven’t placed any bids yet.\nStart playing and try your luck!",
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
                  // Navigator.pushNamed(context, '/home');
                },
                child: const Text(
                  "PLAY NOW",
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
}
