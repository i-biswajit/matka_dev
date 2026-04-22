import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BidRepository {
  final ApiClient apiClient;

  BidRepository({required this.apiClient});

  Future<bool> placeBid({
    required int gameId,
    required String date,
    required String bidTime,
    required String gameType,
    required String digit,
    required String amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    /// 🔹 WALLET VALIDATION
    final walletBalance =
        double.tryParse(prefs.getString('user_balance') ?? '0') ?? 0;

    final enteredAmount = double.tryParse(amount) ?? 0;

    if (enteredAmount <= 0) {
      throw const AppException(
        "Enter valid bid amount",
        statusCode: 400,
      );
    }

    if (enteredAmount > walletBalance) {
      throw const AppException(
        "Insufficient wallet balance",
        statusCode: 400,
      );
    }
    final body = {
      "game_id": gameId,
      "date": date,
      "bid_time": bidTime,
      "game_type": gameType,
      "digit": digit,
      "amount": amount,
    };
    final response = await apiClient.post("place-bid", body);

    final decoded = jsonDecode(response.body);
    print(decoded);

    if (response.statusCode == 200 && decoded['status'] == true) {
      /// Deduct wallet locally
      final newBalance = walletBalance - enteredAmount;

      await prefs.setString(
        'user_balance',
        newBalance.toStringAsFixed(2),
      );

      return true;
    }

    if (response.statusCode == 400 ||
        response.statusCode == 403 ||
        response.statusCode == 422) {
      throw AppException(
        decoded['message'] ?? "Bid not allowed",
        statusCode: response.statusCode,
      );
    }

    String errorMessage = decoded["message"] ?? "Failed to place Bid";

    if (decoded["errors"] is Map && decoded["errors"].isNotEmpty) {
      errorMessage = (decoded["errors"].values.first as List).first.toString();
    }

    throw AppException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}
