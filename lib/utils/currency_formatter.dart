import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  static String format(double value) => _formatter.format(value);
}
