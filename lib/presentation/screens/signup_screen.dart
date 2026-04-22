import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matka_dev/core/utils/launcher_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../bloc/auth/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  String adminNumber = "+917229955541";

  @override
  void initState() {
    super.initState();
    _loadLocalAdminNumber();
  }

  Future<void> _loadLocalAdminNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNumber = prefs.getString('whatsapp_admin');
    if (savedNumber != null) {
      setState(() => adminNumber = savedNumber);
    }
  }

  void _openWhatsApp() {
    LauncherUtils.openUrl("https://wa.me/$adminNumber");
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/login');
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔷 HEADER
              Container(
                height: h * 0.24,
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
                    Icon(Icons.person_add_alt_1,
                        color: Colors.white, size: w * 0.14),
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
                      "Create your new account",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              /// 🔷 FORM CARD
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
                          "Signup",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Fill the details below to continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),

                        SizedBox(height: h * 0.035),

                        _inputField(
                            Icons.person, "Full Name", nameController, w),
                        SizedBox(height: h * 0.02),

                        _inputField(Icons.phone_android, "Mobile Number",
                            mobileController, w,
                            keyboard: TextInputType.phone),
                        SizedBox(height: h * 0.02),

                        _passwordField(passwordController, w),

                        SizedBox(height: h * 0.035),

                        /// 🔹 SIGNUP BUTTON
                        BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          SignupSubmitted(
                                            name: nameController.text,
                                            mobile: mobileController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding:
                                  EdgeInsets.symmetric(vertical: h * 0.022),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(w * 0.08),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: h * 0.025,
                                    width: h * 0.025,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.black),
                                    ),
                                  )
                                : const Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          );
                        }),

                        SizedBox(height: h * 0.025),

                        /// 🔹 LOGIN LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
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

                        SizedBox(height: h * 0.025),

                        /// 🔹 WHATSAPP ADMIN
                        OutlinedButton.icon(
                          onPressed: _openWhatsApp,
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                          ),
                          label: const Text(
                            "Contact Admin",
                            style: TextStyle(color: Colors.green),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(w * 0.08),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: h * 0.018,
                            ),
                          ),
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

  Widget _inputField(
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

  Widget _passwordField(TextEditingController controller, double w) {
    return TextField(
      controller: controller,
      obscureText: obscurePassword,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: kPrimaryColor),
        hintText: "Password",
        filled: true,
        fillColor: kTextFieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.08),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: kPrimaryColor,
          ),
          onPressed: () {
            setState(() => obscurePassword = !obscurePassword);
          },
        ),
      ),
    );
  }
}
