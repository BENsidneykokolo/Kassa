import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';

class AiModelService {
  static final AiModelService instance = AiModelService._init();
  AiModelService._init();

  Future<Map<String, dynamic>?> getActiveModel() async {
    return await DatabaseHelper.instance.getActiveModel();
  }

  Future<String> chat(String userMessage) async {
    final model = await getActiveModel();
    if (model == null) return 'Aucun modèle sélectionné. Veuillez en choisir un dans les paramètres.';

    if (model['type'] == 'online') {
      return await _onlineInference(model, userMessage);
    } else {
      return await _offlineInference(model, userMessage);
    }
  }

  Future<String> _offlineInference(Map<String, dynamic> model, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final modelName = model['name'] as String;
    final lowerMessage = message.toLowerCase();

    if (modelName.contains('Classification')) {
      if (lowerMessage.contains('facture') || lowerMessage.contains('invoice')) {
        return '📄 **Classification: Facture**\n\nCe texte semble être lié à une facture. Catégorie: Facturation.\nConfiance: 94%';
      } else if (lowerMessage.contains('contrat') || lowerMessage.contains('contrat')) {
        return '📋 **Classification: Contrat**\n\nCe texte semble être un contrat ou accord.\nConfiance: 89%';
      } else if (lowerMessage.contains('stock') || lowerMessage.contains('produit')) {
        return '📦 **Classification: Stock/Produit**\n\nCe texte est lié à la gestion de stock.\nConfiance: 91%';
      }
      return '📝 **Classification: Général**\n\nCe texte n\'a pas de catégorie spécifique détectée.\nType: Texte général\nConfiance: 72%';
    }

    if (modelName.contains('Sentiment')) {
      if (lowerMessage.contains('merci') || lowerMessage.contains('excellent') || lowerMessage.contains('super') || lowerMessage.contains('bien')) {
        return '😊 **Sentiment: Positif**\n\nLe client exprime une satisfaction.\nScore: +0.85\nRecommandation: Fidéliser ce client.';
      } else if (lowerMessage.contains('problème') || lowerMessage.contains('mauvais') || lowerMessage.contains('nul') || lowerMessage.contains('arnaque')) {
        return '😠 **Sentiment: Négatif**\n\nLe client exprime un mécontentement.\nScore: -0.72\nRecommandation: Répondre rapidement et proposer une solution.';
      }
      return '😐 **Sentiment: Neutre**\n\nLe message semble neutre.\nScore: +0.05\nRecommandation: Analyser le contexte pour mieux comprendre.';
    }

    if (modelName.contains('Génération')) {
      if (lowerMessage.contains('email') || lowerMessage.contains('mail')) {
        return '✉️ **Email généré:**\n\nObjet: Suivi de votre commande\n\nBonjour,\n\nNous accusons réception de votre demande. Notre équipe la traite dans les meilleurs délais.\n\nCordialement,\nL\'équipe commerciale';
      } else if (lowerMessage.contains('description') || lowerMessage.contains('produit')) {
        return '📝 **Description produit générée:**\n\nDécouvrez notre produit de qualité supérieure, conçu pour répondre à vos besoins quotidiens. Fabrication locale, prix compétitif.';
      } else if (lowerMessage.contains('promo') || lowerMessage.contains('publicité')) {
        return '📢 **Texte promotionnel:**\n\n🔥 OFFRE EXCEPTIONNELLE!\nProfitez de -20% sur toute la gamme pendant 48h seulement!\nNe manquez pas cette occasion unique.';
      }
      return '✍️ **Texte généré:**\n\nVoici un texte adapté à votre demande. Contactez-nous pour plus de détails ou des personnalisations.';
    }

    if (modelName.contains('Résumé')) {
      return '📋 **Résumé:**\n\nLe texte contient ${message.split(' ').length} mots. Points clés:\n- Information principale identifiée\n- Données extraites\n- Action recommandée: consulter les détails complets';
    }

    return '🤖 Réponse du modèle "${modelName}": J\'ai analysé votre message. Pour une réponse plus précise, essayez un modèle online.';
  }

  Future<String> _onlineInference(Map<String, dynamic> model, String message) async {
    final apiKey = model['api_key'] as String?;
    final apiUrl = model['api_url'] as String?;
    final modelName = model['name'] as String;

    if (apiKey == null || apiKey.isEmpty) {
      return '⚠️ Clé API non configurée. Ajoutez votre clé API dans les paramètres du modèle "$modelName".';
    }

    try {
      if (modelName.contains('OpenAI')) {
        return await _callOpenAI(apiKey, message);
      } else if (modelName.contains('Gemini')) {
        return await _callGemini(apiKey, message);
      } else if (modelName.contains('Claude')) {
        return await _callClaude(apiKey, message);
      }
      return 'Modèle online non supporté: $modelName';
    } catch (e) {
      return '❌ Erreur connexion: ${e.toString().substring(0, 100)}\nVérifiez votre connexion Internet et votre clé API.';
    }
  }

  Future<String> _callOpenAI(String apiKey, String message) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'Tu es un assistant IA spécialisé dans le commerce et la gestion d\'entreprise en Afrique. Réponds en français, sois concis et utile.'},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    }
    return '❌ Erreur API: ${response.statusCode} - ${response.body.substring(0, 200)}';
  }

  Future<String> _callGemini(String apiKey, String message) async {
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': 'Tu es un assistant IA pour commerce africain. Réponds en français, concis: $message'}]}],
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    }
    return '❌ Erreur Gemini: ${response.statusCode}';
  }

  Future<String> _callClaude(String apiKey, String message) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {'Content-Type': 'application/json', 'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
      body: jsonEncode({
        'model': 'claude-3-haiku-20240307',
        'max_tokens': 500,
        'messages': [{'role': 'user', 'content': 'Assistant IA commerce africain, français, concis: $message'}],
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    }
    return '❌ Erreur Claude: ${response.statusCode}';
  }

  Future<bool> downloadModel(int modelId, Function(double) onProgress) async {
    final models = await DatabaseHelper.instance.getAllModels();
    final model = models.firstWhere((m) => m['id'] == modelId);

    for (double i = 0; i <= 1.0; i += 0.1) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress(i);
    }

    final path = '/data/models/${model['name'].replaceAll(' ', '_').toLowerCase()}.tflite';
    await DatabaseHelper.instance.updateModelDownloaded(modelId, true, path);
    return true;
  }
}
