import 'package:shared_preferences/shared_preferences.dart';

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

  static const List<Currency> availableCurrencies = [
    Currency(code: 'XAF', symbol: 'FCFA', name: 'Franc CFA (Cameroun, Congo, Gabon, etc.)'),
    Currency(code: 'XOF', symbol: 'FCFA', name: 'Franc CFA (Cote d\'Ivoire, Senegal, Mali, etc.)'),
    Currency(code: 'CDF', symbol: 'FC', name: 'Franc congolais'),
    Currency(code: 'NGN', symbol: '₦', name: 'Naira nigerian'),
    Currency(code: 'GHS', symbol: 'GH₵', name: 'Cedi ghaneen'),
    Currency(code: 'KES', symbol: 'KSh', name: 'Shilling kenyan'),
    Currency(code: 'ZAR', symbol: 'R', name: 'Rand sud-africain'),
    Currency(code: 'USD', symbol: '\$', name: 'Dollar americain', decimalDigits: 2),
    Currency(code: 'EUR', symbol: '€', name: 'Euro', decimalDigits: 2),
    Currency(code: 'GBP', symbol: '£', name: 'Livre sterling', decimalDigits: 2),
  ];

  static Future<Currency> init() async {
    _currentCurrency = await getSelectedCurrency();
    return _currentCurrency;
  }

  static Future<Currency> getSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? defaultCurrency.code;
    return availableCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => defaultCurrency,
    );
  }

  static Future<void> setSelectedCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    _currentCurrency = availableCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => defaultCurrency,
    );
  }

  static String formatPrice(double price, {Currency? currency}) {
    final c = currency ?? _currentCurrency;
    final isDecimal = c.decimalDigits > 0;
    final formatted = isDecimal
        ? price.toStringAsFixed(c.decimalDigits)
        : price.toInt().toString();

    if (!isDecimal) {
      final parts = formatted.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ' ');
      return '$parts ${c.symbol}';
    }

    return '${c.symbol} $formatted';
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
