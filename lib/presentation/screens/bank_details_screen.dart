import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_event.dart';
import 'package:matka_dev/presentation/bloc/wallet/wallet_state.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final nameCtrl = TextEditingController();
  final accCtrl = TextEditingController();
  final confirmAccCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final postalCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadBankDetails());
  }

  bool get isFilled =>
      nameCtrl.text.isNotEmpty &&
      accCtrl.text.isNotEmpty &&
      ifscCtrl.text.isNotEmpty &&
      postalCtrl.text.isNotEmpty &&
      branchCtrl.text.isNotEmpty;
  bool get isVerified => accCtrl.text.isNotEmpty && ifscCtrl.text.isNotEmpty;

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
                  "Bank details submitted successfully",
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
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Bank Details"),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is BankDetailsLoaded) {
            setState(() {
              nameCtrl.text = state.bankData['bank_ac_name'] ?? '';
              accCtrl.text = state.bankData['bank_ac_number'] ?? '';
              ifscCtrl.text = state.bankData['bank_ac_ifsc'] ?? '';
              postalCtrl.text = state.bankData['bank_ac_postal_code'] ?? '';
              branchCtrl.text = state.bankData['bank_ac_branch_address'] ?? '';
            });
          }

          if (state is BankDetailsSuccess) {
            _showSuccess(context, state.message);
          }

          if (state is BankDetailsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            w * 0.05,
            h * 0.03,
            w * 0.05,
            MediaQuery.of(context).viewInsets.bottom + h * 0.03,
          ),
          child: Column(
            children: [
              /// 🧾 Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance,
                        color: kPrimaryColor, size: 32),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: Text(
                        "Enter your bank details carefully.\nWithdrawals will be sent here.",
                        style: TextStyle(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              /// 📝 Form Card
              Container(
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _field("Account Holder Name", Icons.person, nameCtrl,
                        enabled: isEditing || !isFilled),
                    _field("Account Number", Icons.credit_card, accCtrl,
                        enabled: isEditing || !isFilled),
                    if (!isVerified || isEditing)
                      _field(
                        "Confirm Account Number",
                        Icons.credit_card_outlined,
                        confirmAccCtrl,
                        enabled: true,
                      ),
                    _field(
                      "IFSC Code",
                      Icons.code,
                      ifscCtrl,
                      enabled: isEditing || !isFilled,
                      cap: TextCapitalization.characters,
                    ),
                    _field("Postal Code", Icons.location_pin, postalCtrl,
                        enabled: isEditing || !isFilled),
                    _field("Branch Address", Icons.location_on, branchCtrl,
                        enabled: isEditing || !isFilled),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              /// ✅ Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isFilled && !isEditing) {
                      // Switch to edit mode
                      setState(() => isEditing = true);
                    } else {
                      context.read<WalletBloc>().add(
                            UpdateBankDetails(
                              bankAcName: nameCtrl.text.trim(),
                              bankAcNumber: accCtrl.text.trim(),
                              bankIfsc: ifscCtrl.text.trim(),
                              bankPostalCode: postalCtrl.text.trim(),
                              bankBranchAddress: branchCtrl.text.trim(),
                            ),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: h * 0.022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isFilled && !isEditing
                        ? "Edit Details"
                        : "Submit Bank Details",
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.bold,
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

  Widget _field(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool enabled = true,
    TextCapitalization cap = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: cap,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          filled: true,
          fillColor: enabled ? kTextFieldBg : Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
