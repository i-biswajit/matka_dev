import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/colors.dart';
import '../bloc/dashboard/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            title: const Text("Matka Dev"),
            actions: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/wallet'),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet),
                    const SizedBox(width: 5),
                    Text(state.walletBalance.toString()),
                    const SizedBox(width: 15),
                  ],
                ),
              )
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const UserAccountsDrawerHeader(
                  accountName: Text("Biswajit Behera"),
                  accountEmail: Text("9337881379"),
                  currentAccountPicture:
                      CircleAvatar(child: Icon(Icons.person)),
                  decoration: BoxDecoration(color: kPrimaryColor),
                ),
                ...[
                  {"icon": Icons.home, "title": "Home"},
                  {"icon": Icons.person, "title": "Profile"},
                  {"icon": Icons.add, "title": "Add Funds"},
                  {"icon": Icons.remove, "title": "Withdraw Funds"},
                  {"icon": Icons.wallet, "title": "Wallet Statement"},
                  {"icon": Icons.history, "title": "Bid History"},
                  {"icon": Icons.emoji_events, "title": "Win History"},
                  {"icon": Icons.rule, "title": "Game Rates"},
                  {"icon": Icons.info, "title": "Information"},
                  {"icon": Icons.support, "title": "Support"},
                  {"icon": Icons.share, "title": "Share with friends"},
                  {"icon": Icons.star, "title": "Rate App"},
                  {"icon": Icons.password, "title": "Change password"},
                  {"icon": Icons.logout, "title": "Logout"},
                ].map((item) => ListTile(
                      leading: Icon(item["icon"] as IconData),
                      title: Text(item["title"] as String),
                    ))
              ],
            ),
          ),
          body: Column(
            children: [
              // 🔹 TOP HEADER
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome, Biswajit 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 ICON ACTION ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _actionIcon(FontAwesomeIcons.whatsapp, "WhatsApp",
                            Colors.green),
                        _actionIcon(Icons.telegram, "Telegram", Colors.blue),
                        _actionIcon(Icons.star, "Starline", Colors.orange),
                        _actionIcon(
                            Icons.add_circle, "Add Points", Colors.black),
                        _actionIcon(
                            Icons.remove_circle, "Withdraw", Colors.black),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔹 GAME LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.games.length,
                  itemBuilder: (_, index) {
                    return Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.bar_chart, color: kPrimaryColor),
                        title: Text(
                          state.games[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            const Text("Open: 10:00 AM   Close: 11:00 AM"),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle,
                              color: Colors.green),
                          onPressed: () {
                            Navigator.pushNamed(context, '/game');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionIcon(IconData? icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 22,
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        )
      ],
    );
  }
}
