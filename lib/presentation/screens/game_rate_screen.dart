import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/colors.dart';
import '../bloc/game_rate/game_rate_bloc.dart';

class GameRateScreen extends StatelessWidget {
  const GameRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Rates"),
        backgroundColor: kPrimaryColor,
      ),
      body: BlocBuilder<GameRateBloc, GameRateState>(
        builder: (context, state) {
          if (state is GameRateLoading || state is GameRateInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GameRateError) {
            return Center(child: Text(state.message));
          }

          final rates = (state as GameRateLoaded).rates;

          return RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: () async {
              context.read<GameRateBloc>().add(LoadGameRates());
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              itemCount: rates.length,
              itemBuilder: (context, index) {
                final rate = rates[index];
                return Container(
                  margin: EdgeInsets.only(bottom: h * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.018,
                    ),
                    child: Row(
                      children: [
                        /// 🔹 LEFT: GAME NAME
                        SizedBox(
                          width: w * 0.5, // fixed → divider always same place
                          child: Text(
                            rate.name,
                            style: TextStyle(
                              fontSize: h * 0.018,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        /// 🔸 DIVIDER
                        Container(
                          height: h * 0.04,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),

                        SizedBox(width: w * 0.03),

                        /// 🔹 RIGHT: BID / WIN
                        SizedBox(width: w * 0.03),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// BID ROW
                            Row(
                              children: [
                                Text(
                                  "BID ",
                                  style: TextStyle(
                                    fontSize: h * 0.012,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: w * 0.01),
                                Text(
                                  rate.bid,
                                  style: TextStyle(
                                    fontSize: h * 0.017,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: h * 0.008),

                            /// WIN ROW
                            Row(
                              children: [
                                Text(
                                  "WIN ",
                                  style: TextStyle(
                                    fontSize: h * 0.012,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: w * 0.01),
                                Text(
                                  rate.win,
                                  style: TextStyle(
                                    fontSize: h * 0.017,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
