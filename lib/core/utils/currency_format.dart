/// Rupiah formatting without the intl package: 1500000 -> "Rp1.500.000".
String formatRupiah(num amount) {
  final negative = amount < 0;
  final digits = amount.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${negative ? '-' : ''}Rp$buf';
}

/// Short form for chips: 250000 -> "250rb", 1500000 -> "1,5jt" in
/// Indonesian, "250K" and "1.5M" in other languages.
String formatRupiahShort(num amount, {String languageCode = 'id'}) {
  final indonesian = languageCode == 'id';
  if (amount >= 1000000) {
    final v = amount / 1000000;
    final text = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
    return indonesian ? '${text.replaceAll('.', ',')}jt' : '${text}M';
  }
  if (amount >= 1000) {
    return '${(amount / 1000).round()}${indonesian ? 'rb' : 'K'}';
  }
  return amount.round().toString();
}
