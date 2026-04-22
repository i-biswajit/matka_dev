class GameModel {
  final int id;
  final String name;
  final String openTime;
  final String closeTime;
  final int status;
  final int createdBy;
  final int deleted;
  final GameResult? result;

  GameModel({
    required this.id,
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.status,
    required this.createdBy,
    required this.deleted,
    this.result,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      name: json['name'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
      status: json['status'],
      createdBy: json['created_by'],
      deleted: json['deleted'],
      result:
          json['result'] != null ? GameResult.fromJson(json['result']) : null,
    );
  }
}

class GameResult {
  final int id;
  final int gameId;
  final String date;
  final int? openDigit;
  final int? openPanna;
  final int? closeDigit;
  final int? closePanna;
  final int createdBy;

  GameResult({
    required this.id,
    required this.gameId,
    required this.date,
    required this.openDigit,
    required this.openPanna,
    required this.closeDigit,
    required this.closePanna,
    required this.createdBy,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      id: json['id'],
      gameId: json['game_id'],
      date: json['date'],
      openDigit: json['open_digit'],
      openPanna: json['open_panna'],
      closeDigit: json['close_digit'],
      closePanna: json['close_panna'],
      createdBy: json['created_by'],
    );
  }
}
