import 'package:matka_dev/data/models/settings_model.dart';
import 'package:matka_dev/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static Future<void> saveLoginData({
    required String token,
    required String refreshToken,
    required UserModel user,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_code', user.code);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('mobile', user.mobile);
    await prefs.setString('user_balance', user.balance);

    // Optional defaults
    await prefs.setString('user_type', 'user');
    await prefs.setInt('user_status', 1);
  }

  // Auto-login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  //get-token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  //get-refresh-token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Settings
  // ---------- SAVE SETTINGS ----------
  static Future<void> saveSettings(SettingsModel s) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('merchant_id', s.merchantId);
    await prefs.setString('home_text', s.homeText);
    await prefs.setString('phone_number', s.phoneNumber);
    await prefs.setString('phone_number2', s.phoneNumber2);
    await prefs.setString('phone_number3', s.phoneNumber3);
    await prefs.setString('phone_number4', s.phoneNumber4);
    await prefs.setString('telegram', s.telegram);
    await prefs.setString('website_link', s.websiteLink);
    await prefs.setString('facebook_link', s.faceBookLink);
    await prefs.setString('instagram_link', s.instagramLink);
    await prefs.setString('youtube_link', s.youtubeLink);
    await prefs.setString('whatsapp_number', s.whatsappNumber);
    await prefs.setString('start_time', s.startTime);
    await prefs.setString('end_time', s.endTime);

    await prefs.setInt('min_deposit', s.minDeposit);
    await prefs.setInt('max_deposit', s.maxDeposit);
    await prefs.setInt('min_withdrawal', s.minWithdrawal);
    await prefs.setInt('max_withdrawal', s.maxWithdrawal);
    await prefs.setInt('min_bid_amt', s.minBidAmt);
    await prefs.setInt('max_bid_amt', s.maxBidAmt);
    await prefs.setInt('welcome_bonus', s.welcomeBonus);

    await prefs.setString('whatsapp_url', s.whatsappUrl);
    await prefs.setString('telegram_url', s.telegramUrl);
  }

  // ---------- GET SETTINGS ----------
  static Future<SettingsModel?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('merchant_id')) return null;

    return SettingsModel(
      merchantId: prefs.getString('merchant_id') ?? '',
      homeText: prefs.getString('home_text') ?? '',
      phoneNumber: prefs.getString('phone_number') ?? '',
      phoneNumber2: prefs.getString('phone_number2') ?? '',
      phoneNumber3: prefs.getString('phone_number3') ?? '',
      phoneNumber4: prefs.getString('phone_number4') ?? '',
      telegram: prefs.getString('telegram') ?? '',
      websiteLink: prefs.getString('website_link') ?? '',
      faceBookLink: prefs.getString('facebook_link') ?? '',
      instagramLink: prefs.getString('instagram_link') ?? '',
      youtubeLink: prefs.getString('youtube_link') ?? '',
      whatsappNumber: prefs.getString('whatsapp_number') ?? '',
      startTime: prefs.getString('start_time') ?? '',
      endTime: prefs.getString('end_time') ?? '',
      minDeposit: prefs.getInt('min_deposit') ?? 0,
      maxDeposit: prefs.getInt('max_deposit') ?? 0,
      minWithdrawal: prefs.getInt('min_withdrawal') ?? 0,
      maxWithdrawal: prefs.getInt('max_withdrawal') ?? 0,
      minBidAmt: prefs.getInt('min_bid_amt') ?? 0,
      maxBidAmt: prefs.getInt('max_bid_amt') ?? 0,
      welcomeBonus: prefs.getInt('welcome_bonus') ?? 0,
      whatsappUrl: prefs.getString('whatsapp_url') ?? '',
      telegramUrl: prefs.getString('telegram_url') ?? '',
    );
  }

  // ---------- QUICK ACCESS (AddFund) ----------
  static Future<String?> getMerchantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('merchant_id');
  }

  static Future<String?> getMinWithdraw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('min_withdrawal').toString();
  }

  static Future<String?> getMaxWithdraw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('max_withdrawal').toString();
  }

  static Future<String?> getMinDeposit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('min_deposit').toString();
  }

  static Future<String?> getMaxDeposit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('max_deposit').toString();
  }

  static Future<String?> getMinBidAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('min_bid_amt').toString();
  }

  static Future<String?> getMaxBidAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('max_bid_amt').toString();
  }

  static Future<String?> getUserBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_balance').toString();
  }

  static Future<void> setUserBalance(String balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_balance', balance);
  }
}
