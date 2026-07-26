
class Currency {
  final String code;
  final String symbol;
  final String name;
  final int decimalDigits;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimalDigits = 0,
  });
}

class CurrencyService {
  static const String _prefsKey = 'selected_currency';
  static const Currency defaultCurrency = Currency(
    code: 'XAF',
    symbol: 'FCFA',
    name: 'Franc CFA',
    decimalDigits: 0,
  );

  static Currency _currentCurrency = defaultCurrency;

  static Currency get currentCurrency => _currentCurrency;

  static String formatPrice(double price, {Currency? currency}) {
    final c = currency ?? _currentCurrency;
    return '${price.toInt()} ${c.symbol}';
  }

  static String formatPriceCompact(double price, {Currency? currency}) {
    final c = currency ?? _currentCurrency;

    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M ${c.symbol}';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K ${c.symbol}';
    }

    return '${price.toInt()} ${c.symbol}';
  }
}

String fmtPrice(double price) => CurrencyService.formatPrice(price);
String fmtPriceCompact(double price) => CurrencyService.formatPriceCompact(price);
