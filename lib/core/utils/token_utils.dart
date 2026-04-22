import 'dart:convert';

class TokenUtils {
  static bool isExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

    final exp = payload['exp'];
    if (exp == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

    return DateTime.now().isAfter(expiryDate);
  }
}
