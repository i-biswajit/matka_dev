import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/data/models/app_game_model.dart';
import 'package:matka_dev/data/models/game_model.dart';
import '../../core/constants/colors.dart';
import '../bloc/game/game_bloc.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.marketGame});
  final GameModel marketGame;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(
          LoadGames(widget.marketGame.id),
        );
  }

  bool _isBeforeOpenTime() {
    final now = DateTime.now();
    final parts = widget.marketGame.openTime.split(":");

    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return now.isBefore(openTime);
  }

  bool _isOpenResultDeclared() {
    return widget.marketGame.result?.openDigit != null ||
        widget.marketGame.result?.openPanna != null;
  }

  bool _canPlayJodi() {
    if (!_isBeforeOpenTime()) return false; // after open → no
    if (_isOpenResultDeclared()) return false; // result declared → no
    return true;
  }

  bool _canPlayFullSangam() {
    if (!_isBeforeOpenTime()) return false;
    if (_isOpenResultDeclared()) return false;
    if (widget.marketGame.result?.closeDigit != null ||
        widget.marketGame.result?.closePanna != null) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Game"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameNavigate) {
            Navigator.pushNamed(
              context,
              '/play-game',
              arguments: {
                "marketGame": state.marketGame,
                "playType": state.playType,
              },
            );
          }
        },
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is GameLoading || state is GameInitial) {
              return const Center(
                  child: CircularProgressIndicator(
                color: kPrimaryColor,
              ));
            }

            if (state is GameLoaded) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.02,
                  vertical: h * 0.01,
                ),
                child: GridView.builder(
                  itemCount: state.games.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: w * 0.02,
                    mainAxisSpacing: h * 0.005,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final AppGame game = state.games[index];

                    final isJodiBlocked =
                        game.name == "jodi_digit" && !_canPlayJodi();
                    final isFullSangamBlocked =
                        game.name == "full_sangam" && !_canPlayFullSangam();

                    final isBlocked = isJodiBlocked || isFullSangamBlocked;

                    return Opacity(
                      opacity: isBlocked ? 0.5 : 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isBlocked
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      game.name == "jodi_digit"
                                          ? "Jodi game is closed now"
                                          : "Full Sangam is closed now",
                                    ),
                                  ),
                                );
                              }
                            : () {
                                context.read<GameBloc>().add(
                                      GameSelected(
                                        marketGame: widget.marketGame,
                                        game: game,
                                      ),
                                    );
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(w * 0.015),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /// 🔹 GAME IMAGE
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kPrimaryColor.withOpacity(0.1),
                                  ),
                                  child: ClipRRect(
                                    child: Image.network(
                                      game.image,
                                      width: w * 0.10,
                                      height: w * 0.10,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.videogame_asset,
                                          size: 36),
                                    ),
                                  ),
                                ),

                                SizedBox(height: h * 0.015),

                                /// 🔹 GAME NAME
                                Text(
                                  game.name.replaceAll('_', ' ').toUpperCase(),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: h * 0.018,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                SizedBox(height: h * 0.012),

                                /// 🔹 BID / WIN CHIPS
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _rateChip(
                                        "BID",
                                        formatAmount(game.bidRate.toString()),
                                        Colors.black),
                                    SizedBox(width: w * 0.02),
                                    _rateChip(
                                        "WIN",
                                        formatAmount(game.winRate.toString()),
                                        kPrimaryColor),
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
              );
            }
            if (state is GameNavigate) {
              return const SizedBox.shrink(); // keep previous UI
            }

            return const Center(
              child: Text("Something went wrong"),
            );
          },
        ),
      ),
    );
  }

  Widget _rateChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        "$label ₹$value",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

String formatAmount(String value) {
  final num = int.tryParse(value) ?? 0;
  if (num >= 10000000) return "${(num / 10000000).toStringAsFixed(1)}Cr";
  if (num >= 100000) return "${(num / 100000).toStringAsFixed(1)}L";
  if (num >= 1000) return "${(num / 1000).toStringAsFixed(1)}K";
  return num.toString();
}
