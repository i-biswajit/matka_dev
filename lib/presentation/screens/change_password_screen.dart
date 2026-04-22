import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/presentation/bloc/password_update/password_update_bloc.dart';
import '../../core/constants/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Change Password"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocListener<PasswordUpdateBloc, PasswordUpdateState>(
          listener: (context, state) {
            if (state is PasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }

            if (state is PasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Column(
              children: [
                SizedBox(height: h * 0.05),

                /// 🔐 Icon Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 48,
                    color: kPrimaryColor,
                  ),
                ),

                SizedBox(height: h * 0.025),

                /// 📝 Title
                Text(
                  "Set New Password",
                  style: TextStyle(
                    fontSize: h * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Your password must be 6 digits",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: h * 0.04),

                /// 🧾 Card Container
                Card(
                  elevation: 8,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.06),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          /// 🔑 Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: obscurePassword,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: kPrimaryColor,
                              ),
                              hintText: "Enter new password",
                              counterText: "",
                              filled: true,
                              fillColor: kTextFieldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length != 6) {
                                return "Password must be exactly 6 digits";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: h * 0.03),

                          /// 🔘 Submit Button
                          BlocBuilder<PasswordUpdateBloc, PasswordUpdateState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    padding: EdgeInsets.symmetric(
                                        vertical: h * 0.018),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: state is PasswordLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context
                                                .read<PasswordUpdateBloc>()
                                                .add(
                                                  PasswordUpdateRequested(
                                                    newPassword:
                                                        _passwordController.text
                                                            .trim(),
                                                  ),
                                                );
                                          }
                                        },
                                  child: state is PasswordLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "UPDATE PASSWORD",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            },
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
      ),
    );
  }
}
