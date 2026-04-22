class AppGame {
  final String name;
  final String image;
  final int bidRate;
  final int winRate;

  AppGame({
    required this.name,
    required this.image,
    required this.bidRate,
    required this.winRate,
  });

  factory AppGame.fromJson(Map<String, dynamic> json) {
    return AppGame(
      name: json['name'],
      image: json['image'],
      bidRate: json['bid_rate'],
      winRate: json['win_rate'],
    );
  }
}
