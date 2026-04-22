import 'dart:convert';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/network/api_client.dart';
import '../models/game_rate_model.dart';
import '../models/game_rate_response_model.dart';

class GameRateRepository {
  final ApiClient apiClient;

  GameRateRepository({required this.apiClient});

  Future<List<GameRateModel>> fetchRates() async {
    final response = await apiClient.get("game-rates");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = GameRateResponseModel.fromJson(jsonData);
      return toUIList(apiResponse.data);
    }

    final decoded = jsonDecode(response.body);
    String errorMessage =
        decoded["message"] ?? "Failed to fetch Game Rates. Please Try again";

    if (decoded["errors"] != null && decoded["errors"] is Map) {
      final errors = decoded["errors"] as Map;
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

List<GameRateModel> toUIList(GameRateData data) {
  return [
    GameRateModel(
        name: "Single Digit",
        bid: data.singleDigitBid.toString(),
        win: data.singleDigitWin.toString()),
    GameRateModel(
        name: "Jodi Digit",
        bid: data.jodiDigitBid.toString(),
        win: data.jodiDigitWin.toString()),
    GameRateModel(
        name: "Single Panna",
        bid: data.singlePannaBid.toString(),
        win: data.singlePannaWin.toString()),
    GameRateModel(
        name: "Double Panna",
        bid: data.doublePannaBid.toString(),
        win: data.doublePannaWin.toString()),
    GameRateModel(
        name: "Triple Panna",
        bid: data.triplePannaBid.toString(),
        win: data.triplePannaWin.toString()),
    GameRateModel(
        name: "Half Sangam",
        bid: data.halfSangamBid.toString(),
        win: data.halfSangamWin.toString()),
    GameRateModel(
        name: "Full Sangam",
        bid: data.fullSangamBid.toString(),
        win: data.fullSangamWin.toString()),
  ];
}
