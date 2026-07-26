import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static Future<void> openWhatsApp(String phone, {String? message}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final encodedMessage = Uri.encodeComponent(message ?? 'Bonjour');
    final url = 'https://wa.me/$cleanPhone?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir WhatsApp');
    }
  }

  static Future<void> shareSignatureViaWhatsApp({
    required String phone,
    required String documentName,
    required String signerName,
  }) async {
    final message = 'Signature pour le document "$documentName" - Signataire: $signerName';
    await openWhatsApp(phone, message: message);
  }

  static String formatPhoneForWhatsApp(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+225$cleaned';
    }
    return cleaned;
  }

  static bool isWhatsAppAvailable() {
    return true;
  }
}
