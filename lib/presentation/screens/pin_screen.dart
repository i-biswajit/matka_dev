import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/colors.dart';
import '../bloc/pin/pin_bloc.dart';
import '../bloc/pin/pin_event.dart';
import '../bloc/pin/pin_state.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final List<String> pin = ['', '', '', ''];

  @override
  void initState() {
    super.initState();
    _resetPin();
  }

  void _addDigit(String digit) {
    for (int i = 0; i < 4; i++) {
      if (pin[i].isEmpty) {
        setState(() => pin[i] = digit);
        break;
      }
    }

    if (pin.every((p) => p.isNotEmpty)) {
      context.read<PinBloc>().add(PinSubmitted(pin.join()));
    }
  }

  void _deleteDigit() {
    for (int i = 3; i >= 0; i--) {
      if (pin[i].isNotEmpty) {
        setState(() => pin[i] = '');
        break;
      }
    }
  }

  void _resetPin() {
    setState(() {
      for (int i = 0; i < 4; i++) {
        pin[i] = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        _resetPin();
        return true;
      },
      child: Scaffold(
        body: BlocListener<PinBloc, PinState>(
          listener: (context, state) {
            if (state is PinSuccess) {
              _resetPin();
              Navigator.pushReplacementNamed(context, '/dashboard');
            }

            if (state is PinFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              _resetPin();
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// 🔥 GRADIENT HEADER
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.22,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryLightColor, kPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 50),
                        SizedBox(height: 10),
                        Text(
                          "Provide Security PIN",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔢 PIN BOXES
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: kPrimaryColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        pin[index].isEmpty ? '' : '•',
                        style: const TextStyle(fontSize: 24),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                /// 🔢 NUMERIC KEYPAD (3 per row)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 👈 3 buttons per row
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    String label;
                    if (index == 9) {
                      label = 'reset';
                    } else if (index == 10) {
                      label = '0';
                    } else if (index == 11) {
                      label = 'Del';
                    } else {
                      label = '${index + 1}';
                    }

                    return GestureDetector(
                      onTap: () {
                        if (label == 'reset') {
                          _resetPin(); // 👈 clear all 4 digits
                        } else if (label == 'Del') {
                          _deleteDigit();
                        } else if (label.isNotEmpty &&
                            pin.where((e) => e.isNotEmpty).length < 4) {
                          _addDigit(label);
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            label == 'Del' ? Colors.red : kPrimaryColor,
                        child: label == 'reset'
                            ? const Icon(Icons.refresh,
                                color: Colors.white, size: 24)
                            : label == 'del'
                                ? const Icon(Icons.backspace,
                                    color: Colors.white, size: 22)
                                : Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                /// 🟢 ADMIN BUTTON
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "ADMIN",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
