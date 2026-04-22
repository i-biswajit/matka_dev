import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matka_dev/core/config/app_config.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:matka_dev/core/network/token_manager.dart';
import 'package:matka_dev/data/repositories/auth_repository.dart';
import 'package:matka_dev/data/repositories/bid_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/colors.dart';
import '../../core/utils/string_extension.dart';
import '../../data/models/app_game_model.dart';
import '../../data/models/game_model.dart';
import '../bloc/play_game/play_game_bloc.dart';

enum GameInputMode {
  single,
  double,
  triple,
  sangamHalf,
  sangamFull,
}

class PlayGameScreen extends StatefulWidget {
  final GameModel marketGame;
  final AppGame playType;

  const PlayGameScreen({
    super.key,
    required this.marketGame,
    required this.playType,
  });

  @override
  State<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends State<PlayGameScreen> {
  final digitController = TextEditingController();
  final openController = TextEditingController();
  final closeController = TextEditingController();
  final amountController = TextEditingController();
  final autoHalfController = TextEditingController();
  final autoOpenController = TextEditingController();
  final autoCloseController = TextEditingController();

  String _balance = '0';
  bool _balanceLoading = true;
  String selectedDigitGroup = "0";
  String selectedOpenDigitGroup = "0";
  String selectedCloseDigitGroup = "0";

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getString('user_balance') ?? '0';
      _balanceLoading = false;
    });
  }

  @override
  void dispose() {
    digitController.dispose();
    openController.dispose();
    closeController.dispose();
    amountController.dispose();
    autoHalfController.dispose();
    autoOpenController.dispose();
    autoCloseController.dispose();
    super.dispose();
  }

  // ---------------- GAME MODE ----------------

  GameInputMode getInputMode(String gameType) {
    switch (gameType) {
      case "single_digit":
        return GameInputMode.single;
      case "jodi_digit":
        return GameInputMode.double;
      case "single_panna":
      case "double_panna":
      case "triple_panna":
        return GameInputMode.triple;
      case "half_sangam":
        return GameInputMode.sangamHalf;
      case "full_sangam":
        return GameInputMode.sangamFull;
      default:
        return GameInputMode.single;
    }
  }

  // ---------------- HELPERS ----------------

  Widget _numberField(
    TextEditingController controller,
    String label,
    int maxLength, {
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (_) => onChanged?.call(),
    );
  }

  // ---------------- INPUT UI ----------------
  Widget buildDigitInputs(GameInputMode mode) {
    switch (mode) {
      case GameInputMode.single:
        final digits = generateDigits("single_digit");

        return numberGrid(
          numbers: digits,
          selectedValue: digitController.text,
          crossAxisCount: 5,
          onTap: (val) {
            setState(() {
              digitController.text = val;
            });
          },
        );

      case GameInputMode.double:
        final jodi = generateDigits("jodi_digit");

        return numberGrid(
          numbers: jodi,
          selectedValue: digitController.text,
          crossAxisCount: 5,
          onTap: (val) {
            setState(() {
              digitController.text = val;
            });
          },
        );

      case GameInputMode.triple:
        final grouped = generateGroupedPanna(widget.playType.name);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Digit",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            /// 🔹 DIGIT SELECTOR (0-9)
            Wrap(
              spacing: 8,
              children: List.generate(10, (index) {
                final d = index.toString();
                final isSelected = selectedDigitGroup == d;

                return SizedBox(
                  width: 45, // 👈 keeps proper grid feel for 0-9
                  child: selectionItem(
                    text: d,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedDigitGroup = d;
                        digitController.clear();
                      });
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            /// 🔹 PANNA LIST
            const Text(
              "Select Panna",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: grouped[selectedDigitGroup]!.map(
                (panna) {
                  final isSelected = digitController.text == panna;

                  return SizedBox(
                    width: 70, // 👈 important for grid-like alignment
                    child: selectionItem(
                      text: panna,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          digitController.text = panna;
                        });
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        );

      case GameInputMode.sangamHalf:
        final grouped = generateGroupedPanna("single_panna");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Digit",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            /// DIGIT SELECT
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                final d = index.toString();
                final isSelected = selectedDigitGroup == d;

                return SizedBox(
                  width: 45,
                  child: selectionItem(
                    text: d,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedDigitGroup = d;
                        digitController.clear(); // reset only this
                      });
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            const Text("Select Panna",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            /// PANNA SELECT
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: grouped[selectedDigitGroup]!.map((panna) {
                final isSelected = digitController.text == panna;

                return SizedBox(
                  width: 70,
                  child: selectionItem(
                    text: panna,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        digitController.text = panna;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
          ],
        );

      case GameInputMode.sangamFull:
        final grouped = generateGroupedPanna("single_panna");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 OPEN
            const Text("Open Panna",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                final d = index.toString();
                final isSelected = selectedOpenDigitGroup == d;

                return SizedBox(
                  width: 45,
                  child: selectionItem(
                    text: d,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedOpenDigitGroup = d;
                        openController.clear();
                      });
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: grouped[selectedOpenDigitGroup]!.map((panna) {
                final isSelected = openController.text == panna;

                return SizedBox(
                  width: 70,
                  child: selectionItem(
                    text: panna,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        openController.text = panna;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            /// 🔹 CLOSE
            const Text("Close Panna",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                final d = index.toString();
                final isSelected = selectedCloseDigitGroup == d;

                return SizedBox(
                  width: 45,
                  child: selectionItem(
                    text: d,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedCloseDigitGroup = d;
                        closeController.clear();
                      });
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: grouped[selectedCloseDigitGroup]!.map((panna) {
                final isSelected = closeController.text == panna;

                return SizedBox(
                  width: 70,
                  child: selectionItem(
                    text: panna,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        closeController.text = panna;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
          ],
        );

      default:
        return _numberField(digitController, "Enter Digit", 1);
    }
  }

  String getLastDigit(String value) {
    final sum =
        value.split('').map((e) => int.parse(e)).reduce((a, b) => a + b);

    return (sum % 10).toString();
  }

  List<String> generateDigits(String gameType) {
    final List<String> result = [];

    switch (gameType) {
      case "single_digit":
        for (int i = 0; i <= 9; i++) {
          result.add(i.toString());
        }
        break;

      case "jodi_digit":
        for (int i = 0; i <= 99; i++) {
          result.add(i.toString().padLeft(2, '0'));
        }
        break;

      case "single_panna":
        for (int i = 0; i <= 9; i++) {
          for (int j = 0; j <= 9; j++) {
            for (int k = 0; k <= 9; k++) {
              final s = "$i$j$k";
              if (s.split('').toSet().length == 3) {
                result.add(s);
              }
            }
          }
        }
        break;

      case "double_panna":
        for (int i = 0; i <= 9; i++) {
          for (int j = 0; j <= 9; j++) {
            for (int k = 0; k <= 9; k++) {
              final s = "$i$j$k";
              final chars = s.split('');
              if (chars.toSet().length == 2 &&
                  (chars[0] == chars[1] || chars[1] == chars[2])) {
                result.add(s);
              }
            }
          }
        }
        break;

      case "triple_panna":
        for (int i = 0; i <= 9; i++) {
          result.add("$i$i$i");
        }
        break;

      default:
        return [];
    }

    return result.toSet().toList(); // distinct
  }

  // ---------------- FINAL DIGIT ----------------

  String prepareFinalDigit(GameInputMode mode) {
    switch (mode) {
      case GameInputMode.single:
      case GameInputMode.double:
      case GameInputMode.triple:
        return digitController.text;

      case GameInputMode.sangamHalf:
        final panna = digitController.text;
        final auto = getLastDigit(panna);
        return panna + auto;

      case GameInputMode.sangamFull:
        final open = openController.text;
        final close = closeController.text;

        final openAuto = getLastDigit(open);
        final closeAuto = getLastDigit(close);

        return open + openAuto + close + closeAuto;
    }
  }

  Widget _biddingClosedMessage(PlayGameState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Bidding has not started yet. Please wait for market open time.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final inputMode = getInputMode(widget.playType.name);
    final baseUrl = AppConfig.of(context).baseUrl;
// 1️⃣ Create AuthRepository first
    final authRepository = AuthRepository(
      baseUrl: baseUrl,
    );
// 2️⃣ Pass it to TokenManager
    final tokenManager = TokenManager(
      authRepository: authRepository,
    );
// 3️⃣ Create ApiClient
    final apiClient = ApiClient(
      baseUrl: baseUrl,
      tokenManager: tokenManager,
    );

    return BlocProvider(
      create: (_) => PlayGameBloc(
        marketGame: widget.marketGame,
        playType: widget.playType,
        repository: BidRepository(
          apiClient: apiClient,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(widget.playType.name.toTitleCase()),
        ),
        body: BlocConsumer<PlayGameBloc, PlayGameState>(
          listener: (context, state) async {
            if (state is PlayGameError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }

            if (state is PlayGameBidSuccess) {
              //Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );

              //Clear fields
              digitController.clear();
              openController.clear();
              closeController.clear();
              amountController.clear();
              autoHalfController.clear();
              autoOpenController.clear();
              autoCloseController.clear();

              //Refresh balance
              await _loadBalance();
            }
          },
          builder: (context, state) {
            final isLoading = state is PlayGameLoading;
            final bloc = context.read<PlayGameBloc>();

            final canOpen = bloc.canPlayOpen();
            final canClose = bloc.canPlayClose();

            final currentAllowed = state.isOpen ? canOpen : canClose;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (!canOpen && !canClose) ...[
                          _biddingClosedMessage(state),
                          const SizedBox(height: 16),
                        ],

                        /// BALANCE
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(FontAwesomeIcons.wallet,
                                  color: kPrimaryColor),
                              const SizedBox(width: 12),
                              _balanceLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      "₹ $_balance",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// OPEN / CLOSE
                        if (inputMode != GameInputMode.double &&
                            inputMode != GameInputMode.sangamFull)
                          ToggleButtons(
                            isSelected: [state.isOpen, !state.isOpen],
                            onPressed: (i) {
                              if (i == 0 && !canOpen) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Open bidding is closed")),
                                );
                                return;
                              }

                              if (i == 1 && !canClose) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Close bidding is closed")),
                                );
                                return;
                              }

                              context.read<PlayGameBloc>().add(
                                    ToggleOpenClose(i == 0),
                                  );
                            },
                            borderRadius: BorderRadius.circular(30),
                            selectedColor: Colors.white,
                            fillColor: kPrimaryColor,
                            color: Colors.grey,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  "OPEN",
                                  style: TextStyle(
                                    color: canOpen ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  "CLOSE",
                                  style: TextStyle(
                                    color:
                                        canClose ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),

                        /// DIGITS
                        IgnorePointer(
                          ignoring: !currentAllowed,
                          child: Opacity(
                            opacity: currentAllowed ? 1 : 0.5,
                            child: Column(
                              children: [
                                buildDigitInputs(inputMode),
                                const SizedBox(height: 12),
                                _numberField(
                                    amountController, "Enter Funds", 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// SUBMIT
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!currentAllowed || isLoading)
                          ? null
                          : () {
                              final digit = prepareFinalDigit(inputMode);

                              if (amountController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Enter amount")),
                                );
                                return;
                              }

                              context.read<PlayGameBloc>().add(
                                    PlaceBid(
                                      gameId: widget.marketGame.id,
                                      date: DateTime.now()
                                          .toString()
                                          .split(' ')[0],
                                      bidTime:
                                          inputMode == GameInputMode.double ||
                                                  inputMode ==
                                                      GameInputMode.sangamFull
                                              ? "full"
                                              : state.isOpen
                                                  ? "open"
                                                  : "close",
                                      gameType: widget.playType.name,
                                      digit: digit,
                                      amount: amountController.text.trim(),
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: kPrimaryColor)
                          : const Text("PLACE BID",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget numberGrid({
    required List<String> numbers,
    required Function(String) onTap,
    required String selectedValue,
    int crossAxisCount = 5,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: numbers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final num = numbers[index];

        return selectionItem(
          text: num,
          isSelected: num == selectedValue,
          onTap: () => onTap(num),
        );
      },
    );
  }

  Map<String, List<String>> generateGroupedPanna(String type) {
    final Map<String, List<String>> grouped = {
      for (int i = 0; i <= 9; i++) i.toString(): []
    };

    List<String> pannas = generateDigits(type);

    for (var panna in pannas) {
      final sum =
          panna.split('').map((e) => int.parse(e)).reduce((a, b) => a + b);

      final digit = (sum % 10).toString();

      grouped[digit]!.add(panna);
    }

    return grouped;
  }

  Widget selectionItem({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kPrimaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryColor : kPrimaryColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 6,
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
