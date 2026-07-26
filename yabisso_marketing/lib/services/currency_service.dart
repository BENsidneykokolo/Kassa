import 'package:intl/intl.dart';

class CurrencyService {
  static const String defaultCurrency = 'FCFA';
  static const String defaultLocale = 'fr_FR';

  static String formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: defaultLocale,
      symbol: defaultCurrency,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatAmountWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: defaultLocale,
      symbol: defaultCurrency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $defaultCurrency';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $defaultCurrency';
    }
    return '${amount.toStringAsFixed(0)} $defaultCurrency';
  }

  static String get currencyCode => defaultCurrency;
  static String get currencySymbol => defaultCurrency;
}
