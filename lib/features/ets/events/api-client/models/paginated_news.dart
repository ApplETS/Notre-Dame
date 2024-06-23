import 'package:ets_api_clients/models.dart';

class PaginatedNews {
  /// Page Number
  final int pageNumber;

  /// Page Size
  final int pageSize;

  /// Total Pages
  final int totalPages;

  /// Total Records
  final int totalRecords;

  /// News
  final List<News> news;

  PaginatedNews(
      {required this.pageNumber,
      required this.pageSize,
      required this.totalPages,
      required this.totalRecords,
      required this.news});

  factory PaginatedNews.fromJson(Map<String, dynamic> map) => PaginatedNews(
      pageNumber: map['pageNumber'] as int,
      pageSize: map['pageSize'] as int,
      totalPages: map['totalPages'] as int,
      totalRecords: map['totalRecords'] as int,
      news: (map['data'] as List<dynamic>)
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList());

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'totalPages': totalPages,
        'totalRecords': totalRecords,
        'data': news,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedNews &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize &&
          totalPages == other.totalPages &&
          totalRecords == other.totalRecords &&
          news == other.news;

  @override
  int get hashCode =>
      pageNumber.hashCode ^
      pageSize.hashCode ^
      totalPages.hashCode ^
      totalRecords.hashCode ^
      news.hashCode;
}
