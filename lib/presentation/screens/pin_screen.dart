// ignore_for_file: deprecated_member_use

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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

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
                  height: h * 0.25,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimaryLightColor, kPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(w * 0.12),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: w * 0.12),
                        SizedBox(height: h * 0.035),
                        Text(
                          "Provide Security PIN",
                          style: TextStyle(
                              color: Colors.white, fontSize: w * 0.045),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: h * 0.05),

                /// 🔢 PIN BOXES
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.all(w * 0.02),
                      width: w * 0.12,
                      height: w * 0.12,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: kPrimaryColor, width: w * 0.005),
                        borderRadius: BorderRadius.circular(w * 0.025),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        pin[index].isEmpty ? '' : '•',
                        style: TextStyle(fontSize: w * 0.055),
                      ),
                    );
                  }),
                ),

                SizedBox(height: h * 0.03),

                /// 🔢 NUMERIC KEYPAD (3 per row)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: w * 0.14),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: w * 0.07,
                    mainAxisSpacing: h * 0.035,
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
                        radius: w * 0.075,
                        backgroundColor:
                            label == 'Del' ? Colors.red : kPrimaryColor,
                        child: label == 'reset'
                            ? Icon(Icons.refresh,
                                color: Colors.white, size: w * 0.055)
                            : label == 'del'
                                ? Icon(Icons.backspace,
                                    color: Colors.white, size: w * 0.055)
                                : Text(
                                    label,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: w * 0.045,
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
                  icon: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: w * 0.05,
                  ),
                  label: const Text(
                    "ADMIN",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.08),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 0.08, vertical: h * 0.02),
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
