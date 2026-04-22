class SettingsModel {
  final String merchantId;
  final String homeText;
  final String phoneNumber;
  final String phoneNumber2;
  final String phoneNumber3;
  final String phoneNumber4;
  final String telegram;
  final String websiteLink;
  final String faceBookLink;
  final String instagramLink;
  final String youtubeLink;
  final String whatsappNumber;
  final String startTime;
  final String endTime;
  final int minDeposit;
  final int maxDeposit;
  final int minWithdrawal;
  final int maxWithdrawal;
  final int minBidAmt;
  final int maxBidAmt;
  final int welcomeBonus;
  final String whatsappUrl;
  final String telegramUrl;

  SettingsModel({
    required this.merchantId,
    required this.homeText,
    required this.phoneNumber,
    required this.phoneNumber2,
    required this.phoneNumber3,
    required this.phoneNumber4,
    required this.telegram,
    required this.websiteLink,
    required this.faceBookLink,
    required this.instagramLink,
    required this.youtubeLink,
    required this.whatsappNumber,
    required this.startTime,
    required this.endTime,
    required this.minDeposit,
    required this.maxDeposit,
    required this.minWithdrawal,
    required this.maxWithdrawal,
    required this.minBidAmt,
    required this.maxBidAmt,
    required this.welcomeBonus,
    required this.whatsappUrl,
    required this.telegramUrl,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      merchantId: json['merchant_id']?.toString() ?? '',
      homeText: json['home_text'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      phoneNumber2: json['phone_number2'] ?? '',
      phoneNumber3: json['phone_number3'] ?? '',
      phoneNumber4: json['phone_number4'] ?? '',
      telegram: json['telegram'] ?? '',
      websiteLink: json['website_link'] ?? '',
      faceBookLink: json['facebook_link'] ?? '',
      instagramLink: json['instagram_link'] ?? '',
      youtubeLink: json['youtube_link'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      minDeposit: json['min_deposit'] ?? 0,
      maxDeposit: json['max_deposit'] ?? 0,
      minWithdrawal: json['min_withdrawal'] ?? 0,
      maxWithdrawal: json['max_withdrawal'] ?? 0,
      minBidAmt: json['min_bid_amt'] ?? 0,
      maxBidAmt: json['max_bid_amt'] ?? 0,
      welcomeBonus: json['welcome_bonus'] ?? 0,
      whatsappUrl: json['whatsapp_url'] ?? '',
      telegramUrl: json['telegram_url'] ?? '',
    );
  }
}
