/// Data-class that represents a report
class Report {
  /// Report reason
  final String reason;

  /// Report category
  final String category;

  Report({
    required this.reason,
    required this.category,
  });

  /// Used to create [Organizer] instance from a JSON file
  factory Report.fromJson(Map<String, dynamic> map) => Report(
        reason: map['reason'] as String,
        category: map['category'] as String,
      );

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'category': category,
      };
}
