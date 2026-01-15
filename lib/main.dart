import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/game/game_event.dart';
import 'presentation/bloc/pin/pin_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';
import 'presentation/bloc/game/game_bloc.dart';

import 'presentation/bloc/wallet/wallet_event.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/pin_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/wallet_screen.dart';
import 'presentation/screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => PinBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Matka Dev',
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/forgot_password': (_) => const ForgotPasswordScreen(),
          '/pin': (_) => const PinScreen(),

          // 🔹 Route-level blocs
          '/dashboard': (_) => BlocProvider(
                create: (_) => DashboardBloc()..add(LoadDashboard()),
                child: const DashboardScreen(),
              ),

          '/wallet': (_) => BlocProvider(
                create: (_) => WalletBloc()..add(LoadWallet()),
                child: const WalletScreen(),
              ),

          '/game': (_) => BlocProvider(
                create: (_) => GameBloc()..add(LoadGames()),
                child: const GameScreen(),
              ),
        },
      ),
    );
  }
}
