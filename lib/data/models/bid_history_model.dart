class BidHistory {
  final int id;
  final String date;
  final String bidTime;
  final String gameType;
  final int digit;
  final String amount;
  final int winAmount;
  final int isWin;
  final Game game;

  BidHistory({
    required this.id,
    required this.date,
    required this.bidTime,
    required this.gameType,
    required this.digit,
    required this.amount,
    required this.winAmount,
    required this.isWin,
    required this.game,
  });

  factory BidHistory.fromJson(Map<String, dynamic> json) {
    return BidHistory(
        id: json['id'],
        date: json['date'],
        bidTime: json['bid_time'],
        gameType: json['game_type'],
        digit: json['digit'],
        amount: json['amount'],
        winAmount: json['win_amount'],
        isWin: json['is_win'],
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
