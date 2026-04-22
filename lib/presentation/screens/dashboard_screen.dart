// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/core/utils/annimation.dart';
import 'package:matka_dev/core/utils/app_share_utils.dart';
import 'package:matka_dev/core/utils/launcher_utils.dart';
import 'package:matka_dev/data/models/game_model.dart';
import 'package:matka_dev/presentation/bloc/settings/settings_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';
import 'package:matka_dev/presentation/screens/add_funds_screen.dart';
import 'package:matka_dev/presentation/screens/withdraw_funds_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../core/constants/colors.dart';
import '../bloc/dashboard/dashboard_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  String _homeText =
      "🔥 Play smart • Win big • Fast payouts • Trusted platform 🔥";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🔹 Load dashboard & wallet initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(LoadDashboard());
      context.read<WalletBloc>().add(LoadWallet());
      context.read<SettingsBloc>().add(LoadSettings());
    });
    _loadHomeText();
  }

  Future<void> _loadHomeText() async {
    final settings = await AuthStorage.getSettings();

    if (settings != null && settings.homeText.trim().isNotEmpty) {
      setState(() {
        _homeText = settings.homeText;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardBloc>().add(LoadDashboard());
      context.read<WalletBloc>().add(LoadWallet());
      context.read<SettingsBloc>().add(LoadSettings());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshDashboard(BuildContext context) async {
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<WalletBloc>().add(LoadWallet());
    context.read<SettingsBloc>().add(LoadSettings());
  }

  int? _shakingIndex;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    const cardSplClr = Color.fromARGB(255, 239, 1, 1);
    double rText(double size) => size.clamp(12, 22);

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WithdrawSuccess || state is WalletPaymentSuccess) {
          context.read<WalletBloc>().add(LoadWallet());
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is DashboardError) {
            return Scaffold(
              body: Center(child: Text(state.message)),
            );
          }
          if (state is! DashboardLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final loadedState = state;

          return Stack(children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: kPrimaryColor,
                title: const Text("Matka Dev"),
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/wallet'),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.wallet,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          BlocBuilder<WalletBloc, WalletState>(
                            builder: (context, state) {
                              if (state is WalletLoaded) {
                                return Text(
                                  "₹${state.balance}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              if (state is WalletLoading) {
                                return const Text(
                                  "₹...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              return const Text(
                                "₹0",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              /// 🔹 DRAWER
              drawer: Drawer(
                child: Container(
                  color: Colors.white, // solid background
                  child: Column(
                    children: [
                      /// HEADER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: kPrimaryColor, // solid header color
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icons/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loadedState.userName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    loadedState.mobile,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// DRAWER ITEMS
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            _drawerItem(Icons.home, "Home", context),
                            _drawerItem(Icons.person, "Profile", context),
                            _drawerItem(Icons.add, "Add Funds", context),
                            _drawerItem(
                                Icons.remove, "Withdraw Funds", context),
                            _drawerItem(Icons.add_box_outlined,
                                "Add Funds History", context),
                            _drawerItem(FontAwesomeIcons.wallet,
                                "Wallet Statement", context),
                            _drawerItem(Icons.history, "Bid History", context),
                            _drawerItem(
                                Icons.emoji_events, "Win History", context),
                            _drawerItem(Icons.rule, "Game Rates", context),
                            _drawerItem(Icons.info, "Information", context),
                            _drawerItem(Icons.support, "Support", context),
                            _drawerItem(
                                Icons.share, "Share with friends", context),
                            _drawerItem(Icons.star, "Rate App", context),
                            _drawerItem(
                                Icons.password, "Change password", context),

                            /// LOGOUT
                            ListTile(
                              leading:
                                  const Icon(Icons.logout, color: Colors.red),
                              title: const Text("Logout"),
                              onTap: () async {
                                final shouldLogout = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 🔴 Icon
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.logout,
                                                color: Colors.red,
                                                size: 32,
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            const Text(
                                              "Confirm Logout",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            const Text(
                                              "Are you sure you want to logout from your account?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),

                                            const SizedBox(height: 24),

                                            Row(
                                              children: [
                                                // Cancel Button
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      side: const BorderSide(
                                                          color: kPrimaryColor,
                                                          width: 1.5),
                                                      foregroundColor:
                                                          kPrimaryColor,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                    child: const Text("Cancel"),
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                // Logout Button
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    child: const Text(
                                                      "Logout",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                if (shouldLogout == true) {
                                  context.read<DashboardBloc>().add(
                                        DashboardLogoutRequested(),
                                      );

                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔹 BODY
              body: Column(
                children: [
                  /// 🔹 HEADER
                  Container(
                    padding: EdgeInsets.all(h * 0.015),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, ${loadedState.userName} 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: rText(rText(h * 0.02)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: h * 0.015),
                        BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, state) {
                          String marqueeText = _homeText; // fallback to default
                          if (state is SettingsLoaded &&
                              state.settings.homeText.isNotEmpty) {
                            marqueeText = state.settings.homeText;
                          }
                          return SizedBox(
                            height: h * 0.025,
                            width: double.infinity,
                            child: Marquee(
                              text: marqueeText,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: h * 0.015,
                                fontWeight: FontWeight.w500,
                              ),
                              scrollAxis: Axis.horizontal,
                              blankSpace: 40,
                              velocity: 30, // speed
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 10,
                              accelerationDuration: const Duration(seconds: 1),
                              decelerationDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        }),

                        SizedBox(height: h * 0.015),

                        /// ACTION ICONS
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      BlocBuilder<SettingsBloc, SettingsState>(
                                    builder: (context, state) {
                                      if (state is SettingsLoaded) {
                                        return GestureDetector(
                                          onTap: () async {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            final name =
                                                prefs.getString('user_name') ??
                                                    '';
                                            final mobile =
                                                prefs.getString('mobile') ?? '';

                                            final message =
                                                "Hello Sir !!\n\nMy Name is $name.\nMy Mobile Number is $mobile.";

                                            // Encode message for URL
                                            final encodedMessage =
                                                Uri.encodeComponent(message);

                                            LauncherUtils.openUrl(
                                                "${state.settings.whatsappUrl}?text=$encodedMessage");
                                          },
                                          child: _actionIcon(
                                            FontAwesomeIcons.whatsapp,
                                            "WhatsApp",
                                            Colors.green,
                                            h,
                                            w,
                                          ),
                                        );
                                      }

                                      // keep space even while loading
                                      return _actionIcon(
                                        FontAwesomeIcons.whatsapp,
                                        "WhatsApp",
                                        Colors.green,
                                        h,
                                        w,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child:
                                      BlocBuilder<SettingsBloc, SettingsState>(
                                    builder: (context, state) {
                                      if (state is SettingsLoaded) {
                                        return GestureDetector(
                                          onTap: () => LauncherUtils.openUrl(
                                              state.settings.telegramUrl),
                                          child: _actionIcon(
                                            FontAwesomeIcons.telegram,
                                            "Telegram",
                                            Colors.blue,
                                            h,
                                            w,
                                          ),
                                        );
                                      }

                                      // keep space even while loading
                                      return _actionIcon(
                                        FontAwesomeIcons.telegram,
                                        "Telegram",
                                        Colors.blue,
                                        h,
                                        w,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child: _actionIcon(Icons.star, "Starline",
                                      Colors.orange, h, w),
                                ),
                              ],
                            ),
                            SizedBox(height: h * 0.015),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<WalletBloc>(),
                                            child: const AddFundsScreen(),
                                          ),
                                        ),
                                      );

                                      context
                                          .read<WalletBloc>()
                                          .add(LoadWallet()); // 🔥 refresh
                                    },
                                    child: _actionIcon(Icons.add_circle,
                                        "Add Funds", Colors.black, h, w),
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<WalletBloc>(),
                                            child: const WithdrawFundsScreen(),
                                          ),
                                        ),
                                      );

                                      context
                                          .read<WalletBloc>()
                                          .add(LoadWallet()); // 🔥 refresh
                                    },
                                    child: _actionIcon(Icons.remove_circle,
                                        "Withdraw", Colors.black, h, w),
                                  ),
                                ),
                                SizedBox(width: w * 0.02),

                                /// 🔄 REFRESH BUTTON
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _refreshDashboard(context),
                                    child: _actionIcon(Icons.refresh, "Refresh",
                                        Colors.black, h, w),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// 🔹 GAME LIST
                  Expanded(
                    child: RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () => _refreshDashboard(context),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: w > 600 ? 600 : double.infinity,
                          ),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: loadedState.games.length,
                            itemBuilder: (_, index) {
                              final game = loadedState.games[index];
                              // final closed = isGameFullyClosed(game);
                              final closed = isGameClosed(game);

                              return ShakeWidget(
                                shake: _shakingIndex == index,
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: w * 0.001,
                                      vertical: h * 0.004),
                                  child: InkWell(
                                    onTap: () async {
                                      final isResultDeclared =
                                          game.result != null;
                                      if (closed) {
                                        if (await Vibration.hasVibrator() ??
                                            false) {
                                          Vibration.vibrate(duration: 500);
                                        }
                                        showToast(
                                          context,
                                          isResultDeclared
                                              ? "Result already declared"
                                              : "Game is closed",
                                        );

                                        // 🎯 Card shake
                                        setState(() {
                                          _shakingIndex = index;
                                        });

                                        // reset shake after animation
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          if (mounted) {
                                            setState(
                                                () => _shakingIndex = null);
                                          }
                                        });
                                        return;
                                      }

                                      await Navigator.pushNamed(
                                        context,
                                        '/game',
                                        arguments: game,
                                      );

                                      context.read<WalletBloc>().add(
                                          LoadWallet()); // 🔥 refresh after bid
                                    },
                                    splashColor: closed
                                        ? cardSplClr.withOpacity(0.25)
                                        : null,
                                    highlightColor: closed
                                        ? cardSplClr.withOpacity(0.15)
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: EdgeInsets.all(h * 0.01),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(width: w * 0.02),

                                          /// LEADING
                                          Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/chart',
                                                  );
                                                },
                                                child: CircleAvatar(
                                                  radius: h * 0.025,
                                                  backgroundColor:
                                                      kPrimaryColor,
                                                  child: Icon(
                                                    Icons.bar_chart,
                                                    size: h * 0.04,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          /// TITLE + SUBTITLE
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  game.name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          rText(h * 0.02)),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: h * 0.005),
                                                Text(
                                                  getResultText(game),
                                                  style: TextStyle(
                                                    fontSize: h * 0.020,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: h * 0.005),
                                                Row(
                                                  children: [
                                                    /// OPEN
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text("Open:",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      h * 0.015,
                                                                  color: Colors
                                                                      .grey)),
                                                          Text(game.openTime,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ],
                                                      ),
                                                    ),

                                                    /// CLOSE
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text("Close:",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      h * 0.015,
                                                                  color: Colors
                                                                      .grey)),
                                                          Text(game.closeTime,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(width: w * 0.03),

                                          /// TRAILING
                                          closed
                                              ? Column(
                                                  children: [
                                                    Text("CLOSED",
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 239, 1, 1),
                                                            fontSize: h * 0.012,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    SizedBox(height: h * 0.005),
                                                    Icon(
                                                        Icons
                                                            .motion_photos_paused,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 239, 1, 1),
                                                        size: h * 0.05),
                                                    SizedBox(height: h * 0.005),
                                                    Text("PLAY GAME",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: h * 0.012,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text("RUNNING",
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                5, 124, 31),
                                                            fontSize: h * 0.012,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    SizedBox(height: h * 0.005),
                                                    RunningPlayButton(
                                                      onTap: () async {
                                                        await Navigator
                                                            .pushNamed(
                                                          context,
                                                          '/game',
                                                          arguments: game,
                                                        );

                                                        context
                                                            .read<WalletBloc>()
                                                            .add(
                                                                LoadWallet()); // 🔥 refresh after bid
                                                      },
                                                    ),
                                                    SizedBox(height: h * 0.005),
                                                    Text("PLAY GAME",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: h * 0.012,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔄 OVERLAY LOADER (NO WHITE SCREEN)
            if (loadedState.isRefreshing)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              ),
          ]);
        },
      ),
    );
  }

  /// 🔹 DRAWER ITEM
  Widget _drawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        Navigator.pop(context); // ✅ always close drawer first

        if (title == "Profile") {
          Navigator.pushNamed(context, '/profile');
        }
        if (title == "Wallet Statement") {
          Navigator.pushNamed(context, '/wallet');
        }
        if (title == "Change password") {
          Navigator.pushNamed(context, '/change-password');
        }
        if (title == "Game Rates") {
          Navigator.pushNamed(context, '/game-rates');
        }
        if (title == "Support") {
          Navigator.pushNamed(context, '/support');
        }
        if (title == "Information") {
          Navigator.pushNamed(context, '/information');
        }
        if (title == "Bid History") {
          Navigator.pushNamed(context, '/bid-history');
        }
        if (title == "Add Funds History") {
          Navigator.pushNamed(context, '/add-funds-history');
        }
        if (title == "Win History") {
          Navigator.pushNamed(context, '/win-history');
        }
        if (title == "Add Funds") {
          // Navigator.pushNamed(context, '/information');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<WalletBloc>(), // pass existing bloc
                child: const AddFundsScreen(),
              ),
            ),
          );
          context.read<WalletBloc>().add(LoadWallet());
        }
        if (title == "Withdraw Funds") {
          // Navigator.pushNamed(context, '/information');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<WalletBloc>(), // pass existing bloc
                child: const WithdrawFundsScreen(),
              ),
            ),
          );
          context.read<WalletBloc>().add(LoadWallet());
        } else if (title == "Share with friends") {
          try {
            AppShareUtils.shareApp();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Could not open link: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        // Home → nothing else (already on dashboard)
      },
    );
  }

  /// 🔹 ACTION ICON
  Widget _actionIcon(
      IconData? icon, String label, Color color, double h, double w) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.014),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: h * 0.025),
          SizedBox(width: w * 0.02),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: h * 0.016,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

bool isGameFullyClosed(GameModel game) {
  // ❌ RESULT DECLARED → CLOSED
  if (game.result != null) return true;

  final now = DateTime.now();

  // Parse close time
  final parts = game.closeTime.split(":");
  final closeHour = int.parse(parts[0]);
  final closeMinute = int.parse(parts[1]);

  DateTime closeTime;

  // Handle midnight / next day closes
  final openHour = int.parse(game.openTime.split(":")[0]);
  if (closeHour == 0 && closeMinute == 0) {
    closeTime = DateTime(now.year, now.month, now.day + 1, 0, 0);
  } else if (closeHour < openHour) {
    closeTime =
        DateTime(now.year, now.month, now.day + 1, closeHour, closeMinute);
  } else {
    closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMinute);
  }

  // Check if time passed
  if (now.isAfter(closeTime)) return true;

  return false;
}

bool isGameClosed(GameModel game) {
  final now = DateTime.now();

  // ✅ If CLOSE result declared → CLOSED
  if (game.result?.closeDigit != null || game.result?.closePanna != null) {
    return true;
  }

  // Parse close time
  final parts = game.closeTime.split(":");
  final closeHour = int.parse(parts[0]);
  final closeMinute = int.parse(parts[1]);

  DateTime closeTime;

  if (closeHour == 0 && closeMinute == 0) {
    closeTime = DateTime(now.year, now.month, now.day + 1, 0, 0);
  } else {
    closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMinute);
  }

  // ✅ After close time → CLOSED
  return now.isAfter(closeTime);
}

String getResultText(GameModel game) {
  if (game.result == null) return "***_**_***";
  final r = game.result!;
  final openDigit = r.openDigit ?? '*';
  final openPanna = r.openPanna ?? '***';
  final closeDigit = r.closeDigit ?? '*';
  final closePanna = r.closePanna ?? '***';
  return "$openDigit-$openPanna | $closeDigit-$closePanna";
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
