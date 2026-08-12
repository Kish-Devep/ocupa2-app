import 'package:intl/intl.dart';

class DateFormats {
  const DateFormats._();

  /// `format: date` del schema — el API espera exactamente YYYY-MM-DD.
  static String apiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String short(DateTime? date) =>
      date == null ? '—' : DateFormat('d MMM y', 'es').format(date);

  static String long(DateTime? date) =>
      date == null ? '—' : DateFormat("d 'de' MMMM 'de' y", 'es').format(date);

  /// "hace 2 días", como en el mockup de Mis Aplicaciones.
  static String relative(DateTime? date) {
    if (date == null) return '—';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 30) return 'hace ${diff.inDays} días';
    return short(date);
  }

  static String money(num? amount, String? currency) {
    if (amount == null) return '—';
    final symbol = switch ((currency ?? 'DOP').toUpperCase()) {
      'USD' => r'US$',
      'DOP' => r'RD$',
      final other => '$other ',
    };
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2, locale: 'es')
        .format(amount);
  }
}
