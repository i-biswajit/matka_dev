import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/colors.dart';
import '../bloc/profile/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();

  bool _isInitialized = false; // IMPORTANT

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => context.read<ProfileBloc>()..add(ProfileLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text("My Profile"),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded && state.successMessage != null) {
              _isInitialized = false;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.successMessage!)));
            }
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoaded) {
              if (!_isInitialized) {
                nameCtrl.text = state.name;
                emailCtrl.text = state.email;
                mobileCtrl.text = state.mobile;
                _isInitialized = true;
              }

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.06,
                    vertical: h * 0.025,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: w * 0.13,
                        backgroundColor: kPrimaryColor,
                        child: Icon(Icons.person,
                            size: w * 0.14, color: Colors.white),
                      ),
                      SizedBox(height: h * 0.03),
                      _field("Name", Icons.person_outline, nameCtrl,
                          state.isEdit, h, w),
                      _field("Email", Icons.email_outlined, emailCtrl,
                          state.isEdit, h, w),
                      _field("Mobile", Icons.phone_outlined, mobileCtrl, false,
                          h, w),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.grey),
                          SizedBox(width: 6),
                          Text(
                            "Mobile number cannot be changed",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.03),
                      SizedBox(
                        width: double.infinity,
                        child: BlocConsumer<ProfileBloc, ProfileState>(
                          listener: (context, state) {
                            if (state is ProfileLoaded &&
                                state.successMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.successMessage!)),
                              );
                            }

                            if (state is ProfileFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error)),
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is ProfileLoading;
                            // IMPORTANT: create separate updating state

                            final isEdit =
                                state is ProfileLoaded ? state.isEdit : false;

                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isEdit ? Colors.green : kPrimaryColor,
                                padding:
                                    EdgeInsets.symmetric(vertical: h * 0.022),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (!isEdit) {
                                        context
                                            .read<ProfileBloc>()
                                            .add(ProfileEditToggled());
                                      } else {
                                        context.read<ProfileBloc>().add(
                                              ProfileUpdateRequested(
                                                name: nameCtrl.text.trim(),
                                                email: emailCtrl.text.trim(),
                                              ),
                                            );
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEdit ? "SAVE CHANGES" : "EDIT PROFILE",
                                      style: TextStyle(
                                        fontSize: w * 0.042,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController ctrl,
    bool enabled,
    h,
    w,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.02),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: w * 0.055),
          labelText: label,
          labelStyle: const TextStyle(color: kPrimaryColor),
          filled: true,
          fillColor: enabled ? kTextFieldBg : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
