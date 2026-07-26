class CurrencyService {
  static String fmtPrice(double amount) {
    return '${amount.toStringAsFixed(0)} FCFA';
  }
}
