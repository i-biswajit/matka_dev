import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/data/models/settings_model.dart';
import 'package:matka_dev/core/network/api_client.dart';

class SettingsRepository {
  final ApiClient apiClient;

  SettingsRepository({required this.apiClient});

  Future<SettingsModel> fetchSettings() async {
    final response = await apiClient.get("settings");

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['status'] == true) {
      return SettingsModel.fromJson(decoded['data']);
    } else {
      String errorMessage = decoded["message"] ?? "Failed to fetch Settings";

      if (decoded["errors"] != null &&
          decoded["errors"] is Map &&
          decoded["errors"].isNotEmpty) {
        errorMessage =
            (decoded["errors"].values.first as List).first.toString();
      }

      throw AppException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }
}
