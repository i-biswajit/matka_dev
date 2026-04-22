import 'package:flutter/material.dart';
import 'package:matka_dev/core/config/app_config.dart';
import 'package:matka_dev/core/utils/token_utils.dart';
import 'package:matka_dev/data/repositories/auth_repository.dart';
import '../../core/storage/auth_storage.dart';
import '../../core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _checkLogin();
  }

  void _checkLogin() async {
    final token = await AuthStorage.getToken();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/signup');
      return;
    }

    if (TokenUtils.isExpired(token)) {
      final authRepo = AuthRepository(baseUrl: AppConfig.of(context).baseUrl);

      final refreshed = await authRepo.refreshToken();

      if (!refreshed) {
        await AuthStorage.logout();
        Navigator.pushReplacementNamed(context, '/signup');
        return;
      }
    }

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, Color(0xFF4A6CF7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO
            Container(
              width: w * 0.28,
              height: w * 0.28,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            /// APP NAME
            const Text(
              "MATKA DEV",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            /// TAGLINE
            Text(
              "Play Smart. Win Big.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 40),

            /// LOADER
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
