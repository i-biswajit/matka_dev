class GameRateResponseModel {
  final bool status;
  final String message;
  final GameRateData data;

  GameRateResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GameRateResponseModel.fromJson(Map<String, dynamic> json) {
    return GameRateResponseModel(
      status: json['status'],
      message: json['message'],
      data: GameRateData.fromJson(json['data']),
    );
  }
}

class GameRateData {
  final int id;
  final int singleDigitBid;
  final int singleDigitWin;
  final int singlePannaBid;
  final int singlePannaWin;
  final int doublePannaBid;
  final int doublePannaWin;
  final int triplePannaBid;
  final int triplePannaWin;
  final int halfSangamBid;
  final int halfSangamWin;
  final int fullSangamBid;
  final int fullSangamWin;
  final int jodiDigitBid;
  final int jodiDigitWin;

  GameRateData({
    required this.id,
    required this.singleDigitBid,
    required this.singleDigitWin,
    required this.singlePannaBid,
    required this.singlePannaWin,
    required this.doublePannaBid,
    required this.doublePannaWin,
    required this.triplePannaBid,
    required this.triplePannaWin,
    required this.halfSangamBid,
    required this.halfSangamWin,
    required this.fullSangamBid,
    required this.fullSangamWin,
    required this.jodiDigitBid,
    required this.jodiDigitWin,
  });

  factory GameRateData.fromJson(Map<String, dynamic> json) {
    return GameRateData(
      id: json['id'],
      singleDigitBid: json['single_digit_bid'],
      singleDigitWin: json['single_digit_win'],
      singlePannaBid: json['single_panna_bid'],
      singlePannaWin: json['single_panna_win'],
      doublePannaBid: json['double_panna_bid'],
      doublePannaWin: json['double_panna_win'],
      triplePannaBid: json['triple_panna_bid'],
      triplePannaWin: json['triple_panna_win'],
      halfSangamBid: json['half_sangam_bid'],
      halfSangamWin: json['half_sangam_win'],
      fullSangamBid: json['full_sangam_bid'],
      fullSangamWin: json['full_sangam_win'],
      jodiDigitBid: json['jodi_digit_bid'],
      jodiDigitWin: json['jodi_digit_win'],
    );
  }
}
