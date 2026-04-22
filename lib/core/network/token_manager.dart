import 'dart:async';

import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/data/repositories/auth_repository.dart';

class TokenManager {
  final AuthRepository authRepository;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  TokenManager({required this.authRepository});

  Future<bool> refreshToken() async {
    // If already refreshing, wait for same refresh result
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final success = await authRepository.refreshToken();

      _refreshCompleter!.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> logout() async {
    await AuthStorage.logout();
  }
}
