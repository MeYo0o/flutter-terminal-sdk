// localization_field.dart

class LocalizationField {
  final String arabic;
  final String english;

  const LocalizationField({
    required this.arabic,
    required this.english,
  });

  factory LocalizationField.fromJson(Map<String, dynamic> json) {
    return LocalizationField(
      arabic: json['arabic'] as String,
      english: json['english'] as String,
    );
  }

  LocalizationField copyWith({
    String? arabic,
    String? english,
  }) {
    return LocalizationField(
      arabic: arabic ?? this.arabic,
      english: english ?? this.english,
    );
  }

  @override
  String toString() =>
      'LocalizationField(arabic: $arabic, english: $english)';
}
