class DocTemplate {
  final String id;
  final String name;
  final String type;
  final String description;
  final String content;

  DocTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.content,
  });

  static List<DocTemplate> get defaults => [
        DocTemplate(
          id: 'facture_01',
          name: 'Facture standard',
          type: 'facture',
          description: 'Facture simple avec détails',
          content:
              'FACTURE N° {{numero}}\n\nDate: {{date}}\nClient: {{client}}\n\n{{lignes}}\n\nTotal: {{total}} FCFA\n\nMerci pour votre confiance.',
        ),
        DocTemplate(
          id: 'devis_01',
          name: 'Devis standard',
          type: 'devis',
          description: 'Devis avec validité',
          content:
              'DEVIS N° {{numero}}\n\nDate: {{date}}\nClient: {{client}}\nValidité: 30 jours\n\n{{lignes}}\n\nTotal: {{total}} FCFA',
        ),
        DocTemplate(
          id: 'bon_01',
          name: 'Bon de commande',
          type: 'bon',
          description: 'Bon de commande simple',
          content:
              'BON DE COMMANDE N° {{numero}}\n\nDate: {{date}}\nFournisseur: {{fournisseur}}\n\n{{lignes}}\n\nTotal: {{total}} FCFA',
        ),
        DocTemplate(
          id: 'recu_01',
          name: 'Reçu de paiement',
          type: 'recu',
          description: 'Reçu simple',
          content:
              'REÇU DE PAIEMENT\n\nDate: {{date}}\nDe: {{client}}\nMontant: {{total}} FCFA\nMotif: {{motif}}\n\nSignature: ___________',
        ),
        DocTemplate(
          id: 'contrat_01',
          name: 'Contrat de prestation',
          type: 'contrat',
          description: 'Contrat simple de prestation de services',
          content:
              'CONTRAT DE PRESTATION\n\nEntre les soussignés:\n\nLe Prestataire: {{prestataire}}\nLe Client: {{client}}\n\nDate: {{date}}\n\nObjet: {{objet}}\n\nConditions:\n{{conditions}}\n\nMontant: {{total}} FCFA\n\nFait à {{lieu}}, le {{date}}\n\nSignature Prestataire: ___________\nSignature Client: ___________',
        ),
        DocTemplate(
          id: 'lettre_01',
          name: 'Lettre commerciale',
          type: 'lettre',
          description: 'Lettre professionnelle',
          content:
              '{{expediteur}}\n\nÀ l\'attention de {{client}}\n\nDate: {{date}}\nObjet: {{objet}}\n\nMadame, Monsieur,\n\n{{corps}}\n\nCordialement,\n\n{{expediteur}}',
        ),
      ];
}
