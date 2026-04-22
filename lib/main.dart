import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matka_dev/core/config/app_config.dart';
import 'package:matka_dev/core/config/environment.dart';
import 'package:matka_dev/core/constants/colors.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:matka_dev/core/network/token_manager.dart';
import 'package:matka_dev/data/models/app_game_model.dart';
import 'package:matka_dev/data/models/game_model.dart';
import 'package:matka_dev/data/repositories/add_funds_history_repository.dart';
import 'package:matka_dev/data/repositories/auth_repository.dart';
import 'package:matka_dev/data/repositories/bid_history_repository.dart';
import 'package:matka_dev/data/repositories/bid_repository.dart';
import 'package:matka_dev/data/repositories/game_rate_repository.dart';
import 'package:matka_dev/data/repositories/game_repository.dart';
import 'package:matka_dev/data/repositories/password_repository.dart';
import 'package:matka_dev/data/repositories/profile_repository.dart';
import 'package:matka_dev/data/repositories/settings_repository.dart';
import 'package:matka_dev/data/repositories/wallet_repository.dart';
import 'package:matka_dev/data/repositories/win_history_repository.dart';
import 'package:matka_dev/presentation/bloc/add_funds_history/add_funds_history_bloc.dart';
import 'package:matka_dev/presentation/bloc/bid_history/bid_history_bloc.dart';
import 'package:matka_dev/presentation/bloc/game_rate/game_rate_bloc.dart';
import 'package:matka_dev/presentation/bloc/password_update/password_update_bloc.dart';
import 'package:matka_dev/presentation/bloc/play_game/play_game_bloc.dart';
import 'package:matka_dev/presentation/bloc/profile/profile_bloc.dart';
import 'package:matka_dev/presentation/bloc/settings/settings_bloc.dart';
import 'package:matka_dev/presentation/bloc/win_history/win_history_bloc.dart';
import 'package:matka_dev/presentation/screens/add_funds_history_screen.dart';
import 'package:matka_dev/presentation/screens/add_funds_screen.dart';
import 'package:matka_dev/presentation/screens/bid_history_screen.dart';
import 'package:matka_dev/presentation/screens/change_password_screen.dart';
import 'package:matka_dev/presentation/screens/chart_screen.dart';
import 'package:matka_dev/presentation/screens/game_rate_screen.dart';
import 'package:matka_dev/presentation/screens/information_screen.dart';
import 'package:matka_dev/presentation/screens/play_game_screen.dart';
import 'package:matka_dev/presentation/screens/profile_screen.dart';
import 'package:matka_dev/presentation/screens/splash_screen.dart';
import 'package:matka_dev/presentation/screens/support_screen.dart';
import 'package:matka_dev/presentation/screens/win_history_screen.dart';
import 'package:matka_dev/presentation/screens/withdraw_funds_screen.dart';

import 'presentation/bloc/auth/auth_bloc.dart';
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
  runApp(
    const AppConfig(
      environment: Environment.prod,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final baseUrl = AppConfig.of(context).baseUrl;

// 1️⃣ Create AuthRepository first
        final authRepository = AuthRepository(
          baseUrl: baseUrl,
        );

// 2️⃣ Pass it to TokenManager
        final tokenManager = TokenManager(
          authRepository: authRepository,
        );

// 3️⃣ Create ApiClient
        final apiClient = ApiClient(
          baseUrl: baseUrl,
          tokenManager: tokenManager,
        );
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthBloc(
                authRepository: AuthRepository(
                  baseUrl: AppConfig.of(context).baseUrl,
                ),
              ),
            ),
            BlocProvider(create: (_) => PinBloc()),
            BlocProvider(
              create: (_) => GameBloc(
                repository: GameRepository(
                  apiClient: apiClient,
                ),
              ),
            ),
            BlocProvider(
              create: (_) => SettingsBloc(
                SettingsRepository(
                  apiClient: apiClient,
                ),
              )..add(LoadSettings()),
            ),
            BlocProvider(
              create: (_) =>
                  WalletBloc(repository: WalletRepository(apiClient: apiClient))
                    ..add(LoadWallet()),
            ),
            BlocProvider(
              create: (_) => DashboardBloc(
                gameRepository: GameRepository(
                  apiClient: apiClient,
                ),
                profileRepository: ProfileRepository(
                  apiClient: apiClient,
                ),
              )..add(LoadDashboard()),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: kPrimaryColor,
                primary: kPrimaryColor,
              ),
            ),
            debugShowCheckedModeBanner: false,
            title: 'Matka Dev',
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/forgot_password': (_) => const ForgotPasswordScreen(),
              '/change-password': (_) => BlocProvider(
                    create: (_) => PasswordUpdateBloc(
                      repository: PasswordRepository(
                        apiClient: apiClient,
                      ),
                    ),
                    child: const ChangePasswordScreen(),
                  ),
              '/pin': (_) => const PinScreen(),
              '/profile': (_) => BlocProvider(
                    create: (_) => ProfileBloc(
                      repository: ProfileRepository(
                        apiClient: apiClient,
                      ),
                    ),
                    child: const ProfileScreen(),
                  ),
              '/dashboard': (_) => BlocProvider(
                    create: (_) => DashboardBloc(
                      gameRepository: GameRepository(
                        apiClient: apiClient,
                      ),
                      profileRepository: ProfileRepository(
                        apiClient: apiClient,
                      ),
                    )..add(LoadDashboard()),
                    child: const DashboardScreen(),
                  ),
              '/wallet': (_) => const WalletScreen(),
              '/game': (context) {
                final game =
                    ModalRoute.of(context)!.settings.arguments as GameModel;
                return BlocProvider.value(
                  value: context.read<GameBloc>()..add(LoadGames(game.id)),
                  child: GameScreen(marketGame: game),
                );
              },
              '/play-game': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;

                return BlocProvider(
                  create: (_) => PlayGameBloc(
                    marketGame: args['marketGame'] as GameModel,
                    playType: args['playType'] as AppGame,
                    repository: BidRepository(
                      apiClient: apiClient,
                    ),
                  ),
                  child: PlayGameScreen(
                      marketGame: args['marketGame'] as GameModel,
                      playType: args['playType'] as AppGame),
                );
              },
              '/game-rates': (context) {
                return BlocProvider(
                  create: (_) => GameRateBloc(
                    repository: GameRateRepository(
                      apiClient: apiClient,
                    ),
                  )..add(LoadGameRates()),
                  child: const GameRateScreen(),
                );
              },
              '/support': (_) => const SupportScreen(),
              '/information': (_) => const InformationScreen(),
              '/add_funds': (_) => const AddFundsScreen(),
              '/withdraw_funds': (_) => const WithdrawFundsScreen(),
              '/chart': (_) => const ChartScreen(),
              '/bid-history': (_) => BlocProvider(
                    create: (_) => BidHistoryBloc(
                      repository: BidHistoryRepository(
                        apiClient: apiClient,
                      ),
                    ),
                    child: const BidHistoryScreen(),
                  ),
              '/add-funds-history': (_) => BlocProvider(
                    create: (_) => AddFundHistoryBloc(
                      repository: AddFundHistoryRepository(
                        apiClient: apiClient,
                      ),
                    )..add(FetchAddFundHistory()),
                    child: const AddFundHistoryScreen(),
                  ),
              '/win-history': (_) => BlocProvider(
                    create: (_) => WinHistoryBloc(
                      repository: WinHistoryRepository(
                        apiClient: apiClient,
                      ),
                    )..add(LoadWinHistory()),
                    child: const WinHistoryScreen(),
                  ),
            },
          ),
        );
      },
    );
  }
}
