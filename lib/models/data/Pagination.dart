
class Pagination {
  final int? totalPages;
  final int currentPage;
  final int? totalData;

  const Pagination({
    this.totalPages,
    required this.currentPage,
    this.totalData,
  });

  /// JSON factory (deserialization)
  factory Pagination.fromJson(dynamic json) {
    return Pagination(
      totalPages: json['total_pages'] as int?,
      currentPage: json['current_page'] as int,
      totalData: json['total_data'] as int?,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'total_pages': totalPages,
      'current_page': currentPage,
      'total_data': totalData,
    };
  }
}