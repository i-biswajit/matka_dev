import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:matka_dev/data/models/bid_history_model.dart';

class BidHistoryRepository {
  final ApiClient apiClient;

  BidHistoryRepository({required this.apiClient});

  Future<List<BidHistory>> fetchBidHistory() async {
    final response = await apiClient.get("bid-history");

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      String errorMessage = decoded["message"] ?? "Failed to fetch Bid History";

      if (decoded["errors"] is Map && decoded["errors"].isNotEmpty) {
        errorMessage =
            (decoded["errors"].values.first as List).first.toString();
      }

      throw AppException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }

    // Safe handling for nested pagination structure
    final List list = decoded['data']?['data'] ?? [];

    return list.map((e) => BidHistory.fromJson(e)).toList();
  }
}
