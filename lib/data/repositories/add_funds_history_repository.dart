import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:matka_dev/data/models/add_funds_history_model.dart';

class AddFundHistoryRepository {
  final ApiClient apiClient;

  AddFundHistoryRepository({required this.apiClient});

  Future<List<AddFundHistoryModel>> fetchHistory() async {
    final response = await apiClient.get("all-fund-requests");

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw AppException(
        decoded['message'] ?? "Failed to load add fund history",
        statusCode: response.statusCode,
      );
    }

    if (decoded['success'] != true) {
      String errorMessage =
          decoded["message"] ?? "Unable to fetch Add Funds History";

      if (decoded["errors"] != null && decoded["errors"] is Map) {
        final errors = decoded["errors"] as Map;
        if (errors.isNotEmpty) {
          errorMessage = (errors.values.first as List).first.toString();
        }
      }

      throw AppException(errorMessage);
    }
    final data = decoded['data'];

    if (data == null || data is! List) {
      return [];
    }

    if (data.isEmpty) {
      return [];
    }
    return (decoded['data'] as List)
        .map((e) => AddFundHistoryModel.fromJson(e))
        .toList();
  }
}
