import 'package:intl/intl.dart';

class PriceFormatter {
  static String format(int price) {
    final formatter = NumberFormat("#,##0");
    return "₦${formatter.format(price)} / Year";
  }
}