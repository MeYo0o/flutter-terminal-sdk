import '../util/json_pick.dart';
import 'dto/language_content.dart';

class LabelValue<T> {
  final LanguageContent label;
  final T value;

  LabelValue({
    required this.label,
    required this.value,
  });

  factory LabelValue.fromJson(Map<String, dynamic> json) {
    return LabelValue(
      label: LanguageContent.fromJson(json['label'] as Map<String, dynamic>),
      value: json['value'] as T,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label.toJson(),
        'value': value,
      };

  static LabelValue<bool> boolFromJson(Map<String, dynamic> json) {
    return LabelValue<bool>(
      label: LanguageContent.fromJson(json['label'] as Map<String, dynamic>),
      value: toBoolSafe(json['value']),
    );
  }

  static LabelValue<String> stringFromJson(Map<String, dynamic> json) {
    return LabelValue<String>(
      label: LanguageContent.fromJson(json['label'] as Map<String, dynamic>),
      value: toStringSafe(json['value']),
    );
  }
}
