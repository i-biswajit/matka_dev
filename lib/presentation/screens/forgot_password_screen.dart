import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/colors.dart';
import '../bloc/auth/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔷 HEADER
              Container(
                height: h * 0.28,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryLightColor, kPrimaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(w * 0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_reset, color: Colors.white, size: 56),
                    SizedBox(height: h * 0.015),
                    Text(
                      "MATKA DEV",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.055,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Reset your password",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 🔷 CARD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.07),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Forgot Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Enter your registered mobile number to receive OTP",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),

                        SizedBox(height: h * 0.035),

                        /// 📱 MOBILE INPUT
                        _buildInputField(
                          Icons.phone_android,
                          "Mobile Number",
                          mobileController,
                          w,
                          keyboard: TextInputType.phone,
                        ),

                        SizedBox(height: h * 0.035),

                        /// 🔹 SEND OTP
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(SendOtp());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: EdgeInsets.symmetric(vertical: h * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(w * 0.08),
                            ),
                          ),
                          child: const Text(
                            "SEND OTP",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.025),

                        /// 🔹 BACK TO LOGIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Remember your password? "),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/login'),
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildInputField(
    IconData icon,
    String hint,
    TextEditingController controller,
    double w, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kPrimaryColor),
        hintText: hint,
        filled: true,
        fillColor: kTextFieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.08),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
