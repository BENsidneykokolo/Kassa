import 'package:intl/intl.dart';

class CurrencyService {
  static const String defaultCurrency = 'FCFA';
  static final NumberFormat _formatter = NumberFormat('#,##0', 'fr_FR');

  static String formatAmount(double amount) {
    return '${_formatter.format(amount.toInt())} $defaultCurrency';
  }

  static String formatAmountShort(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    }
    return '${amount.toInt()} FCFA';
  }

  static String getCurrencySymbol() => 'FCFA';

  static List<String> getAvailableCurrencies() {
    return ['FCFA', 'EUR', 'USD'];
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return "Aujourd'hui";
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else if (diff.inDays < 30) {
      return 'Il y a ${(diff.inDays / 7).floor()} semaines';
    } else {
      return formatDate(date);
    }
  }
}
