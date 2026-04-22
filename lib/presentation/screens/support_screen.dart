import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/core/utils/launcher_utils.dart';
import 'package:matka_dev/presentation/bloc/settings/settings_bloc.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text("Support"),
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
            final s = state.settings;

            return ListView(
              padding: EdgeInsets.all(w * 0.05),
              children: [
                _sectionTitle("📞 Call Support"),
                _supportCard([
                  _supportTile(
                    icon: Icons.phone,
                    text: s.phoneNumber,
                    onTap: () => LauncherUtils.callNumber(s.phoneNumber),
                  ),
                  _supportTile(
                    icon: Icons.phone,
                    text: s.phoneNumber2,
                    onTap: () => LauncherUtils.callNumber(s.phoneNumber2),
                  ),
                  _supportTile(
                    icon: Icons.phone,
                    text: s.phoneNumber3,
                    onTap: () => LauncherUtils.callNumber(s.phoneNumber3),
                  ),
                  _supportTile(
                    icon: Icons.phone,
                    text: s.phoneNumber4,
                    onTap: () => LauncherUtils.callNumber(s.phoneNumber4),
                  ),
                ]),
                SizedBox(height: h * 0.03),
                _sectionTitle("💬 Chat Support"),
                _supportCard([
                  _supportTile(
                    icon: FontAwesomeIcons.whatsapp,
                    text: "WhatsApp Support",
                    iconColor: Colors.green,
                    onTap: () => LauncherUtils.openUrl(s.whatsappUrl),
                  ),
                  _supportTile(
                    icon: FontAwesomeIcons.telegram,
                    text: "Telegram Support",
                    iconColor: Colors.blue,
                    onTap: () => LauncherUtils.openUrl(s.telegramUrl),
                  ),
                ]),
              ],
            );
          }

          return const Center(
            child: Text(
              "Unable to load support details",
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Section Header
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  /// 🔹 Support Card
  Widget _supportCard(List<Widget> children) {
    final visibleChildren = children.where((e) => e is! SizedBox).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          visibleChildren.length,
          (i) => Column(
            children: [
              visibleChildren[i],
              if (i != visibleChildren.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Support Tile
  Widget _supportTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = kPrimaryColor,
  }) {
    if (text.isEmpty) return const SizedBox();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
