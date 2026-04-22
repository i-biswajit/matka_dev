import 'package:url_launcher/url_launcher.dart';

class LauncherUtils {
  static Future<void> callNumber(String number) async {
    if (number.isEmpty) return;

    final uri = Uri.parse("tel:$number");
    await launchUrl(uri);
  }

  static Future<void> openUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
