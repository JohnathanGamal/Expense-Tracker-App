import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(
      double amount, {
        String? symbol = "\$",
        String? name = "EGP",
        String? locale = "en_EG",
      }) {
    return NumberFormat('$symbol##,##,##,###.####', locale).format(amount);
  }
}

