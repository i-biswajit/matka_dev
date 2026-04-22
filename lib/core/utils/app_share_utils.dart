import 'package:share_plus/share_plus.dart';

class AppShareUtils {
  // 🔁 Toggle when Play Store is live
  static const bool isLiveOnPlayStore = false;

  static const String appName = "Matka Dev";

  // 🔗 Update later
  static const String playStoreLink =
      "https://play.google.com/store/apps/details?id=com.your.app";

  static const String comingSoonLink = "https://matkadev.com/public/app";

  static void shareApp() {
    final message = isLiveOnPlayStore ? _liveMessage() : _comingSoonMessage();

    Share.share(
      message,
      subject: appName,
    );
  }

  // 🟢 Play Store live message
  static String _liveMessage() {
    return '''
🔥 $appName 🔥

Play smart. Win big.
Fast payouts & trusted platform.

👉 Download now:
$playStoreLink
''';
  }

  // 🟡 Coming soon message
  static String _comingSoonMessage() {
    return '''
🔥 $appName 🔥

🚀 Launching soon on Play Store!
Get ready for fast games & big wins.

Stay connected:
$comingSoonLink
''';
  }
}
