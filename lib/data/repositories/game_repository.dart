import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import '../models/game_model.dart';
import 'package:matka_dev/data/models/app_game_model.dart';

class GameRepository {
  final ApiClient apiClient;

  GameRepository({required this.apiClient});

  /// 🔹 Fetch Games by date
  Future<List<GameModel>> fetchGames(String date) async {
    final response = await apiClient.get("games-result?date=$date");

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      String errorMessage = decoded["message"] ?? "Failed to Load Games";

      if (decoded["errors"] is Map && decoded["errors"].isNotEmpty) {
        errorMessage =
            (decoded["errors"].values.first as List).first.toString();
      }

      throw AppException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }

    final List data = decoded['data'] ?? [];

    return data.map((e) => GameModel.fromJson(e)).toList();
  }

  /// 🔹 Fetch app games for a market
  Future<List<AppGame>> fetchAppGames({
    required int gameId,
  }) async {
    final body = {
      "game_id": gameId,
    };
    final response = await apiClient.post("app-games-list", body);

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200 || decoded['status'] != true) {
      String errorMessage = decoded["message"] ?? "Failed to Load Games";

      if (decoded["errors"] is Map && decoded["errors"].isNotEmpty) {
        errorMessage =
            (decoded["errors"].values.first as List).first.toString();
      }

      throw AppException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }

    final List list = decoded['data']?['app_games'] ?? [];

    return list.map((e) => AppGame.fromJson(e)).toList();
  }
}
