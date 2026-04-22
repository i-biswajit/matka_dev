import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  Future<String> signup({
    required String name,
    required String mobile,
    required String password,
    String referralCode = "",
  }) async {
    final url = Uri.parse("$baseUrl/register-user");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "mobile": mobile,
        "password": password,
        "referral_code": referralCode,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == true) {
      return data["message"];
    } else {
      String errorMessage = data["message"] ?? "Signup failed";

      if (data["errors"] != null && data["errors"] is Map) {
        final errors = data["errors"] as Map;
        if (errors.isNotEmpty) {
          // Take the first field's first message
          errorMessage = (errors.values.first as List).first.toString();
        }
      }
      throw AppException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  //login

  Future<String> login({
    required String mobile,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobile": mobile,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["token"] != null) {
      final userModel = UserModel.fromJson(data['user']);

      await AuthStorage.saveLoginData(
        token: data["token"],
        refreshToken: data["refresh_token"],
        user: userModel,
      );
      return "Login successful";
    } else {
      if (response.statusCode == 401) {
        throw const AppException(
          "Invalid mobile number or password",
          statusCode: 401,
        );
      }

      String errorMessage = data["message"] ?? "Login failed";

      if (data["errors"] != null && data["errors"] is Map) {
        final errors = data["errors"] as Map;
        if (errors.isNotEmpty) {
          // Take the first field's first message
          errorMessage = (errors.values.first as List).first.toString();
        }
      }
      throw AppException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  //Refresh

  Future<bool> refreshToken() async {
    final oldToken = await AuthStorage.getToken();
    final refreshToken = await AuthStorage.getRefreshToken();

    if (oldToken == null || refreshToken == null) return false;

    final url = Uri.parse("$baseUrl/refresh");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $oldToken",
      },
      body: jsonEncode({
        "refresh_token": refreshToken,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["token"] != null) {
      // 🔥 Only update tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data["token"]);
      await prefs.setString('refresh_token', data["refresh_token"]);

      return true;
    }

    return false;
  }

  //logout
  Future<void> logout() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AppException(
        "Session expired. Please login again.",
        statusCode: 401,
      );
    }

    final url = Uri.parse("$baseUrl/logout");

    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }
}
