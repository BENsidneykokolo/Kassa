import 'package:flutter/material.dart';
import '../../domain/enums.dart';

/// Pastille colorée indiquant le niveau de stock par rapport au seuil.
class StockLevelBadge extends StatelessWidget {
  final double quantity;
  final double threshold;
  final StockUnit unit;

  const StockLevelBadge({
    super.key,
    required this.quantity,
    required this.threshold,
    required this.unit,
  });

  StockAlertLevel get _level {
    if (quantity <= 0) return StockAlertLevel.critique;
    if (quantity <= threshold) return StockAlertLevel.attention;
    return StockAlertLevel.info;
  }

  Color get _color {
    switch (_level) {
      case StockAlertLevel.critique:
        return Colors.red;
      case StockAlertLevel.attention:
        return Colors.orange;
      case StockAlertLevel.info:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)} ${unit.label}',
        style: TextStyle(color: _color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

/// Pastille affichant le nombre de jours avant péremption d'un lot.
class ExpirationBadge extends StatelessWidget {
  final DateTime? expirationDate;

  const ExpirationBadge({super.key, this.expirationDate});

  @override
  Widget build(BuildContext context) {
    if (expirationDate == null) {
      return const SizedBox.shrink();
    }
    final daysLeft = expirationDate!.difference(DateTime.now()).inDays;
    late Color color;
    late String text;

    if (daysLeft < 0) {
      color = Colors.red;
      text = 'Périmé';
    } else if (daysLeft <= 2) {
      color = Colors.red;
      text = 'Expire dans $daysLeft j';
    } else if (daysLeft <= 7) {
      color = Colors.orange;
      text = 'Expire dans $daysLeft j';
    } else {
      color = Colors.grey;
      text = 'DLC : $daysLeft j';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
