import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:matka_dev/data/models/win_history_model.dart';

class WinHistoryRepository {
  final ApiClient apiClient;

  WinHistoryRepository({required this.apiClient});

  Future<List<WinHistory>> fetchWinHistory() async {
    final response = await apiClient.get("win-history");
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == true) {
      final data = WinHistoryResponse.fromJson(body).data;
      return data; // empty list is fine
    } else {
      throw _parseError(body, response.statusCode);
    }
  }

  AppException _parseError(
    Map<String, dynamic> decoded,
    int statusCode,
  ) {
    String errorMessage = decoded["message"] ?? "Failed to load Win History";

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
