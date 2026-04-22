import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/presentation/bloc/settings/settings_bloc.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Information"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.02,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 HEADER
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: kPrimaryColor,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: w * 0.03),
                          Text(
                            "Important Information",
                            style: TextStyle(
                              fontSize: h * 0.022,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: h * 0.02),

                      /// 🔹 DIVIDER
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                      ),

                      SizedBox(height: h * 0.015),

                      /// 🔹 CONTENT
                      Text(
                        state.settings.homeText,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: h * 0.017,
                          height: 1.7,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: Text(
              "No information available",
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
