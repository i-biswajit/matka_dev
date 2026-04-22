import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  Future<UserModel> fetchProfile() async {
    final response = await apiClient.get("profile");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);

      await _saveUserToPrefs(user);
      return user;
    } else {
      final decoded = jsonDecode(response.body);

      String errorMessage = decoded["message"] ?? "Failed to fetch profile";

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

  /// 🔹 Update profile
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await apiClient.post(
      "profile-update",
      {
        "name": name,
        "email": email,
      },
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
    } else {
      final decoded = jsonDecode(response.body);

      String errorMessage = decoded["message"] ?? "Failed to update profile";

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

  /// 🔹 Save user locally
  Future<void> _saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_code', user.code);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('mobile', user.mobile);
    await prefs.setString('balance', user.balance);
  }

  /// 🔹 Load profile from local cache (offline / fast)
  Future<UserModel?> getLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_id')) return null;

    return UserModel(
      id: prefs.getInt('user_id')!,
      code: prefs.getString('user_code') ?? '',
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      mobile: prefs.getString('mobile') ?? '',
      balance: prefs.getString('balance') ?? '0',
    );
  }
}
