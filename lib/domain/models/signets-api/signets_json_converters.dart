// Package imports:
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// Signets returns most numbers as strings using a French decimal separator
/// (ex: "94,9"). An empty string means the value is not available.
double? _parseSignetsDouble(Object? json) {
  if (json == null) return null;
  if (json is num) return json.toDouble();
  final value = json.toString().trim();
  if (value.isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}

int? _parseSignetsInt(Object? json) {
  if (json == null) return null;
  if (json is num) return json.toInt();
  final value = json.toString().trim();
  if (value.isEmpty) return null;
  return int.tryParse(value) ?? double.tryParse(value.replaceAll(',', '.'))?.toInt();
}

/// Nullable double sent as a string (ex: "94,9" or "").
class SignetsDoubleConverter implements JsonConverter<double?, Object?> {
  const SignetsDoubleConverter();

  @override
  double? fromJson(Object? json) => _parseSignetsDouble(json);

  @override
  Object? toJson(double? object) => object;
}

/// Double sent as a string, defaults to 0 when empty.
class SignetsDoubleOrZeroConverter implements JsonConverter<double, Object?> {
  const SignetsDoubleOrZeroConverter();

  @override
  double fromJson(Object? json) => _parseSignetsDouble(json) ?? 0.0;

  @override
  Object? toJson(double object) => object;
}

/// Nullable integer sent as a string (ex: "95" or "").
class SignetsIntConverter implements JsonConverter<int?, Object?> {
  const SignetsIntConverter();

  @override
  int? fromJson(Object? json) => _parseSignetsInt(json);

  @override
  Object? toJson(int? object) => object;
}

/// Integer sent as a string or a number, defaults to 0 when empty.
class SignetsIntOrZeroConverter implements JsonConverter<int, Object?> {
  const SignetsIntOrZeroConverter();

  @override
  int fromJson(Object? json) => _parseSignetsInt(json) ?? 0;

  @override
  Object? toJson(int object) => object;
}

/// Boolean sent as "Oui"/"Non", "true"/"false" or as a JSON boolean.
class SignetsBoolConverter implements JsonConverter<bool, Object?> {
  const SignetsBoolConverter();

  @override
  bool fromJson(Object? json) {
    if (json is bool) return json;
    final value = json?.toString().trim().toLowerCase();
    return value == 'oui' || value == 'true';
  }

  @override
  Object? toJson(bool object) => object;
}

/// String where an empty value means there is no value.
class EmptyStringAsNullConverter implements JsonConverter<String?, Object?> {
  const EmptyStringAsNullConverter();

  @override
  String? fromJson(Object? json) {
    final value = json?.toString();
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Object? toJson(String? object) => object;
}

/// String with trailing spaces removed (Signets pads some fields).
class TrimmedStringConverter implements JsonConverter<String, Object?> {
  const TrimmedStringConverter();

  @override
  String fromJson(Object? json) => (json?.toString() ?? '').trimRight();

  @override
  Object? toJson(String object) => object;
}

/// Decimal number kept as a string, using "." as the decimal separator
/// (ex: "30,0+20" becomes "30.0+20").
class DecimalStringConverter implements JsonConverter<String, Object?> {
  const DecimalStringConverter();

  @override
  String fromJson(Object? json) => (json?.toString() ?? '').trim().replaceAll(',', '.');

  @override
  Object? toJson(String object) => object;
}

/// Nullable date where an empty string means there is no date.
class NullableDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    final value = json?.toString().trim();
    return value == null || value.isEmpty ? null : DateTime.parse(value);
  }

  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}

/// Time of the day sent as "HH:mm" (no date part).
class HourMinuteConverter implements JsonConverter<DateTime, String> {
  const HourMinuteConverter();

  static final DateFormat _format = DateFormat('HH:mm');

  @override
  DateTime fromJson(String json) => _format.parse(json.trim());

  @override
  String toJson(DateTime object) => _format.format(object);
}

/// Locations sent as a single string by the API, but stored as a list.
class LocationListConverter implements JsonConverter<List<String>, Object?> {
  const LocationListConverter();

  @override
  List<String> fromJson(Object? json) {
    if (json == null) return [];
    if (json is List) return json.map((e) => e.toString()).toList();
    return [json.toString()];
  }

  @override
  Object? toJson(List<String> object) => object;
}
