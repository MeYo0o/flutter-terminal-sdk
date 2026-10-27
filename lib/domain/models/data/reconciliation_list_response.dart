import '../util/json_pick.dart';

class ReconciliationListResponse {
  final List<ReconciliationItem> data;
  final Pagination pagination;

  ReconciliationListResponse({required this.data, required this.pagination});

  factory ReconciliationListResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<ReconciliationItem> transactionList = dataList
        .map((data) =>
            ReconciliationItem.fromJson(Map<String, dynamic>.from(data as Map)))
        .toList();
    return ReconciliationListResponse(
      data: transactionList,
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };
}

class ReconciliationItem {
  final String id;
  final String date;
  final String time;
  final String startDate;
  final String startTime;
  final LabelValue isBalanced;
  final String total;
  final Currency currency;

  ReconciliationItem({
    required this.id,
    required this.date,
    required this.time,
    required this.startDate,
    required this.startTime,
    required this.isBalanced,
    required this.total,
    required this.currency,
  });

  factory ReconciliationItem.fromJson(Map<String, dynamic> json) {
    final isBalancedJson = pickKey(json, ['isBalanced', 'is_balanced']);
    return ReconciliationItem(
      id: toStringSafe(json['id']),
      date: toStringSafe(json['date']),
      time: toStringSafe(json['time']),
      startDate: toStringSafe(pickKey(json, ['startDate', 'start_date'])),
      startTime: toStringSafe(pickKey(json, ['startTime', 'start_time'])),
      isBalanced: LabelValue.fromJson(
        isBalancedJson is Map
            ? Map<String, dynamic>.from(isBalancedJson)
            : const {},
      ),
      total: toStringSafe(json['total']),
      currency: Currency.fromJson(
        Map<String, dynamic>.from(json['currency'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'start_date': startDate,
        'start_time': startTime,
        'is_balanced': isBalanced.toJson(),
        'total': total,
        'currency': currency.toJson(),
      };
}

class LabelValue {
  final LanguageContent label;
  final bool value;

  LabelValue({required this.label, required this.value});

  factory LabelValue.fromJson(Map<String, dynamic> json) {
    final labelJson = json['label'];
    return LabelValue(
      label: labelJson is Map
          ? LanguageContent.fromJson(Map<String, dynamic>.from(labelJson))
          : LanguageContent(arabic: '', english: ''),
      value: toBoolSafe(json['value']),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label.toJson(),
        'value': value,
      };
}

class LanguageContent {
  final String arabic;
  final String english;
  final String? turkish;

  LanguageContent({
    required this.arabic,
    required this.english,
    this.turkish,
  });

  factory LanguageContent.fromJson(Map<String, dynamic> json) {
    return LanguageContent(
      arabic: json['arabic'] ?? '',
      english: json['english'] ?? '',
      turkish: json['turkish'],
    );
  }

  Map<String, dynamic> toJson() => {
        'arabic': arabic,
        'english': english,
        'turkish': turkish,
      };
}

class Currency {
  final String? arabic;
  final String english;
  final String turkish;

  Currency({
    this.arabic,
    required this.english,
    required this.turkish,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      arabic: json['arabic'],
      english: json['english'] ?? '',
      turkish: json['turkish'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'arabic': arabic,
        'english': english,
        'turkish': turkish,
      };
}

class Pagination {
  final double totalPages;
  final double currentPage;
  final double totalData;

  Pagination({
    required this.totalPages,
    required this.currentPage,
    required this.totalData,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalPages: toDoubleSafe(pickKey(json, ['total_pages', 'totalPages'])),
      currentPage: toDoubleSafe(pickKey(json, ['current_page', 'currentPage'])),
      totalData: toDoubleSafe(pickKey(json, ['total_data', 'totalData'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_pages': totalPages,
        'current_page': currentPage,
        'total_data': totalData,
      };
}
