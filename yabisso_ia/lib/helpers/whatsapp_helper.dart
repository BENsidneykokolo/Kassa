import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static Future<void> openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/242050332359');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
