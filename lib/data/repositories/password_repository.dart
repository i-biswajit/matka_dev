import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';

class PasswordRepository {
  final ApiClient apiClient;

  PasswordRepository({required this.apiClient});

  Future<bool> updatePassword(String newPassword) async {
    final body = {
      "new_password": newPassword,
    };
    final response = await apiClient.post("password-update", body);

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return true;
    }

    String errorMessage = decoded["message"] ?? "Failed to Update Password";

    if (decoded["errors"] is Map && decoded["errors"].isNotEmpty) {
      errorMessage = (decoded["errors"].values.first as List).first.toString();
    }

    throw AppException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}
