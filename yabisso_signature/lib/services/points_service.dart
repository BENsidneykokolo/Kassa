class PointsService {
  static final PointsService instance = PointsService._init();
  PointsService._init();

  int _totalPoints = 0;
  int _signaturePoints = 0;
  int _pdfPoints = 0;

  int get totalPoints => _totalPoints;
  int get signaturePoints => _signaturePoints;
  int get pdfPoints => _pdfPoints;

  void addSignaturePoints({int count = 10}) {
    _signaturePoints += count;
    _totalPoints += count;
  }

  void addPdfExportPoints({int count = 5}) {
    _pdfPoints += count;
    _totalPoints += count;
  }

  String getFormattedPoints() {
    if (_totalPoints >= 1000000) {
      return '${(_totalPoints / 1000000).toStringAsFixed(1)}M';
    } else if (_totalPoints >= 1000) {
      return '${(_totalPoints / 1000).toStringAsFixed(1)}K';
    }
    return _totalPoints.toString();
  }

  Map<String, dynamic> getStats() {
    return {
      'total': _totalPoints,
      'signatures': _signaturePoints,
      'pdf': _pdfPoints,
    };
  }
}
