// ignore_for_file: invalid_annotation_target

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'replaced_day.freezed.dart';
part 'replaced_day.g.dart';

/// Day replaced by another one (ex: holiday)
@freezed
abstract class ReplacedDay with _$ReplacedDay {
  const factory ReplacedDay({
    /// Original date being replaced (ex: holiday date).
    @JsonKey(name: 'dateOrigine') required DateTime originalDate,

    /// New date when classes will be held instead.
    @JsonKey(name: 'dateRemplacement') required DateTime replacementDate,

    /// Reason for the replacement (ex: "Action de grâces").
    @JsonKey(name: 'description') required String description,
  }) = _ReplacedDay;

  factory ReplacedDay.fromJson(Map<String, dynamic> json) => _$ReplacedDayFromJson(json);
}
