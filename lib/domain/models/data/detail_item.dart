import '../util/json_pick.dart';
import 'dto/language_content.dart';

class DetailItem {
  final LanguageContent label;
  final String total;
  final num count;

  DetailItem({
    required this.label,
    required this.total,
    required this.count,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      label: LanguageContent.fromJson(json['label'] as Map<String, dynamic>),
      total: toStringSafe(json['total']),
      count: toNumSafe(json['count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label.toJson(),
        'total': total,
        'count': count,
      };
}
