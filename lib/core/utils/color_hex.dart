import 'package:flutter/painting.dart';

/// Parses "#RRGGBB" or "#AARRGGBB"; returns [fallback] for anything else.
Color colorFromHex(String hex, {required Color fallback}) {
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = value.length == 8 ? int.tryParse(value, radix: 16) : null;
  return parsed == null ? fallback : Color(parsed);
}
