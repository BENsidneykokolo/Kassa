import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String _number = '242050332359';
  static const String _groupSupport = 'https://chat.whatsapp.com/ETMMkpkg36OGFqi1BQzpAR';
  static const String _groupSubscription = 'https://chat.whatsapp.com/DgT5723rLABBg9tyvm4RZo';

  static Future<void> showChoice({
    required BuildContext context,
    required String message,
    String groupType = 'support',
  }) async {
    final groupUrl = groupType == 'subscription' ? _groupSubscription : _groupSupport;
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Envoyer via WhatsApp',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.phone, color: Colors.white),
              ),
              title: const Text('Numéro WhatsApp'),
              subtitle: const Text('+242 050 332 359'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('https://wa.me/$_number?text=$message');
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.group, color: Colors.white),
              ),
              title: const Text('Groupe WhatsApp'),
              subtitle: const Text('Rejoindre le groupe'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(groupUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
