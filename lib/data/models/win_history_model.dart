class WinHistoryResponse {
  final bool status;
  final String message;
  final List<WinHistory> data;

  WinHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WinHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    final dataList = <WinHistory>[];

    if (rawData != null) {
      if (rawData is List) {
        // normal case: data is a list
        dataList.addAll(rawData.map((e) => WinHistory.fromJson(e)));
      }
    }

    return WinHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: dataList,
    );
  }
}

class WinHistory {
  final int id;
  final String date;
  final String bidTime;
  final String gameType;
  final int digit;
  final String amount;
  final int winAmount;
  final Game game;

  WinHistory({
    required this.id,
    required this.date,
    required this.bidTime,
    required this.gameType,
    required this.digit,
    required this.amount,
    required this.winAmount,
    required this.game,
  });

  factory WinHistory.fromJson(Map<String, dynamic> json) {
    return WinHistory(
        id: json['id'],
        date: json['date'],
        bidTime: json['bid_time'],
        gameType: json['game_type'],
        digit: json['digit'],
        amount: json['amount'],
        winAmount: json['win_amount'],
        game: json['game'] != null
            ? Game.fromJson(json['game'])
            : Game(name: '', openTime: '', closeTime: ''));
  }
}

class Game {
  final String name;
  final String openTime;
  final String closeTime;

  Game({
    required this.name,
    required this.openTime,
    required this.closeTime,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      openTime: json['open_time'],
      closeTime: json['close_time'],
    );
  }
}
