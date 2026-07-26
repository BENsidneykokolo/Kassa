import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static Future<void> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse(
        'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openWhatsAppBusiness({
    required String phoneNumber,
    String? message,
  }) async {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    String url = 'https://wa.me/$cleanedPhone';
    if (message != null && message.isNotEmpty) {
      url += '?text=${Uri.encodeComponent(message)}';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> shareOnWhatsApp({
    required String message,
    List<String>? phoneNumbers,
  }) async {
    final uri = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static bool isWhatsAppNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 9;
  }
}
