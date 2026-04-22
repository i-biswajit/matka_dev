import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  /// 🔹 Fetch Wallet History
  Future<List<WalletTransactionModel>> fetchWalletHistory() async {
    final response = await apiClient.get("wallet-history");
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List list = decoded['data']['data'];

      if (list.isEmpty) {
        throw const AppException(
          "No Wallet history available",
          statusCode: 204,
        );
      }

      return list.map((e) => WalletTransactionModel.fromJson(e)).toList();
    } else {
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 Local Balance
  Future<String> getLocalBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_balance') ?? '0';
  }

  /// 🔹 Update Bank Details
  Future<Map<String, dynamic>> updateBankDetails({
    String? name,
    String? accNumber,
    String? ifsc,
    String? postalCode,
    String? branchAddress,
  }) async {
    final response = await apiClient.post(
      "bank-details-update",
      {
        "bank_ac_name": name,
        "bank_ac_number": accNumber,
        "bank_ac_ifsc": ifsc,
        "bank_ac_postal_code": postalCode,
        "bank_ac_branch_address": branchAddress,
        "phonepe_number": null,
        "gpay_number": null,
        "paytm_number": null,
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded;
    } else {
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 Fetch Bank Details
  Future<Map<String, dynamic>> fetchBankDetails() async {
    final response = await apiClient.get("bank-details");
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded;
    } else {
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 Update UPI Details
  Future<Map<String, dynamic>> updateUpiDetails(
    String app,
    dynamic number,
  ) async {
    switch (app) {
      case "PhonePe":
        app = 'phonepe_number';
        break;
      case "GPay":
        app = 'gpay_number';
        break;
      case "PayTM":
        app = 'paytm_number';
        break;
    }
    final body = {app: number};
    final response = await apiClient.post(
      "bank-details-update",
      body,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded;
    } else {
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 Withdraw
  Future<void> withdraw({
    required double amount,
    required String method,
  }) async {
    final response = await apiClient.post(
      "wallet-withdrawal",
      {
        "amount": amount,
        "method": method,
      },
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 Add Fund
  Future<void> addFund({
    required int amount,
    required String ref,
  }) async {
    final response = await apiClient.post(
      "wallet-add-fund",
      {
        "amount": amount,
        "ref": ref,
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['status'] == true) {
      return;
    } else {
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 UTR Submit
  Future<bool> utrSubmitRequest({
    required int amount,
    required String ref,
  }) async {
    final response = await apiClient.post(
      "wallet-add-fund-request",
      {
        "amount": amount,
        "ref": ref,
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['status'] == true) {
      return true;
    } else {
      throw _parseError(decoded, response.statusCode);
    }
  }

  /// 🔹 Common Error Parser
  AppException _parseError(Map<String, dynamic> decoded, int statusCode) {
    String errorMessage = decoded["message"] ?? "Something went wrong";

    if (decoded["errors"] != null &&
        decoded["errors"] is Map &&
        decoded["errors"].isNotEmpty) {
      errorMessage = (decoded["errors"].values.first as List).first.toString();
    }

    return AppException(
      errorMessage,
      statusCode: statusCode,
    );
  }
}
