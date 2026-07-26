class FileItem {
  final int? id;
  final String name;
  final String? path;
  final String? parentFolderId;
  final String type; // file, folder, image, document, video, audio
  final double sizeBytes;
  final String? mimeType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isDeleted;

  FileItem({this.id, required this.name, this.path, this.parentFolderId, this.type = 'file', this.sizeBytes = 0, this.mimeType, DateTime? createdAt, DateTime? updatedAt, this.isFavorite = false, this.isDeleted = false})
      : createdAt = createdAt ?? DateTime.now(), updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'name': name, 'path': path, 'parent_folder_id': parentFolderId,
    'type': type, 'size_bytes': sizeBytes, 'mime_type': mimeType,
    'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String(),
    'is_favorite': isFavorite ? 1 : 0, 'is_deleted': isDeleted ? 1 : 0,
  };

  factory FileItem.fromMap(Map<String, dynamic> m) => FileItem(
    id: m['id'] as int?, name: m['name'] as String, path: m['path'] as String?,
    parentFolderId: m['parent_folder_id'] as String?, type: m['type'] as String? ?? 'file',
    sizeBytes: (m['size_bytes'] as num?)?.toDouble() ?? 0, mimeType: m['mime_type'] as String?,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
    updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
    isFavorite: (m['is_favorite'] as int?) == 1, isDeleted: (m['is_deleted'] as int?) == 1,
  );

  String get sizeLabel {
    if (sizeBytes < 1024) return '${sizeBytes.round()} B';
    if (sizeBytes < 1048576) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1073741824) return '${(sizeBytes / 1048576).toStringAsFixed(1)} MB';
    return '${(sizeBytes / 1073741824).toStringAsFixed(1)} GB';
  }

  String get typeLabel {
    switch (type) {
      case 'folder': return 'Dossier';
      case 'image': return 'Image';
      case 'document': return 'Document';
      case 'video': return 'Vidéo';
      case 'audio': return 'Audio';
      default: return 'Fichier';
    }
  }
}
