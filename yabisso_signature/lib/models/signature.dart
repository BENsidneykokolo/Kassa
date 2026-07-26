import 'dart:typed_data';

enum SignatureType { dessin, texte, image }

enum SignatureStatus { brouillon, signe, annule }

class SignatureModel {
  final String id;
  final String documentName;
  final String signerName;
  final String signerEmail;
  final String? signaturePath;
  final SignatureType signatureType;
  final SignatureStatus status;
  final DateTime createdAt;
  final Uint8List? signatureBytes;
  final String? fontStyle;
  final String? textColor;

  SignatureModel({
    required this.id,
    required this.documentName,
    required this.signerName,
    required this.signerEmail,
    this.signaturePath,
    required this.signatureType,
    this.status = SignatureStatus.brouillon,
    required this.createdAt,
    this.signatureBytes,
    this.fontStyle,
    this.textColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_name': documentName,
      'signer_name': signerName,
      'signer_email': signerEmail,
      'signature_path': signaturePath,
      'signature_type': signatureType.index,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
      'font_style': fontStyle,
      'text_color': textColor,
    };
  }

  factory SignatureModel.fromMap(Map<String, dynamic> map) {
    return SignatureModel(
      id: map['id'],
      documentName: map['document_name'],
      signerName: map['signer_name'],
      signerEmail: map['signer_email'],
      signaturePath: map['signature_path'],
      signatureType: SignatureType.values[map['signature_type']],
      status: SignatureStatus.values[map['status']],
      createdAt: DateTime.parse(map['created_at']),
      fontStyle: map['font_style'],
      textColor: map['text_color'],
    );
  }

  SignatureModel copyWith({
    String? id,
    String? documentName,
    String? signerName,
    String? signerEmail,
    String? signaturePath,
    SignatureType? signatureType,
    SignatureStatus? status,
    DateTime? createdAt,
    Uint8List? signatureBytes,
    String? fontStyle,
    String? textColor,
  }) {
    return SignatureModel(
      id: id ?? this.id,
      documentName: documentName ?? this.documentName,
      signerName: signerName ?? this.signerName,
      signerEmail: signerEmail ?? this.signerEmail,
      signaturePath: signaturePath ?? this.signaturePath,
      signatureType: signatureType ?? this.signatureType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      signatureBytes: signatureBytes ?? this.signatureBytes,
      fontStyle: fontStyle ?? this.fontStyle,
      textColor: textColor ?? this.textColor,
    );
  }

  String get statusLabel {
    switch (status) {
      case SignatureStatus.brouillon:
        return 'Brouillon';
      case SignatureStatus.signe:
        return 'Signe';
      case SignatureStatus.annule:
        return 'Annule';
    }
  }

  String get typeLabel {
    switch (signatureType) {
      case SignatureType.dessin:
        return 'Dessin';
      case SignatureType.texte:
        return 'Texte';
      case SignatureType.image:
        return 'Image';
    }
  }
}
