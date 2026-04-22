import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';

class UpiDetailsScreen extends StatefulWidget {
  final String upiApp;

  const UpiDetailsScreen(this.upiApp, {super.key});

  @override
  State<UpiDetailsScreen> createState() => _UpiDetailsScreenState();
}

class _UpiDetailsScreenState extends State<UpiDetailsScreen> {
  final numberCtrl = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadUpiDetails(widget.upiApp));
  }

  void _showSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 72),
                SizedBox(height: 12),
                Text(
                  "UPI details submitted successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("${widget.upiApp} Details"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is BankDetailsLoaded) {
            setState(() {
              numberCtrl.text = _getExistingNumber(state.bankData);
              isEditing = numberCtrl.text.isEmpty; // editable if empty
            });
          }

          if (state is BankDetailsSuccess) {
            _showSuccess(context, state.message);
          }

          if (state is BankDetailsFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            w * 0.05,
            w * 0.05,
            w * 0.05,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            children: [
              /// 🔹 HEADER CARD
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: h * 0.04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.upiApp,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Enter your registered mobile number",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 🔹 INPUT FIELD
              _textField(
                  hint: "Mobile Number",
                  icon: Icons.phone_android,
                  controller: numberCtrl,
                  enabled: isEditing),

              SizedBox(height: h * 0.04),

              /// 🔹 SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (!isEditing) {
                      // Switch to edit mode
                      setState(() => isEditing = true);
                    } else {
                      context.read<WalletBloc>().add(
                            UpdateUpiDetails(
                              app: widget.upiApp,
                              number: numberCtrl.text,
                            ),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    !isEditing ? "Edit Details" : "Submit Request",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 MODERN TEXT FIELD
  Widget _textField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        enabled: enabled,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  String _getExistingNumber(Map data) {
    switch (widget.upiApp) {
      case "PhonePe":
        return data['phonepe_number'] ?? '';
      case "GPay":
        return data['gpay_number'] ?? '';
      case "PayTM":
        return data['paytm_number'] ?? '';
      default:
        return '';
    }
  }
}
