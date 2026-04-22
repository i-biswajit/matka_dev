import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matka_dev/core/network/token_manager.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';

class ApiClient {
  final String baseUrl;
  final TokenManager tokenManager;

  ApiClient({
    required this.baseUrl,
    required this.tokenManager,
  });

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    String? token = await AuthStorage.getToken();

    http.Response response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await tokenManager.refreshToken();

      if (!refreshed) {
        await tokenManager.logout();
        throw Exception("Session expired");
      }

      // retry with new token
      token = await AuthStorage.getToken();

      response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    }

    return response;
  }

  Future<http.Response> get(String endpoint) async {
    String? token = await AuthStorage.getToken();

    http.Response response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401) {
      final refreshed = await tokenManager.refreshToken();

      if (!refreshed) {
        await tokenManager.logout();
        throw Exception("Session expired");
      }

      token = await AuthStorage.getToken();

      response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    }

    return response;
  }
}
