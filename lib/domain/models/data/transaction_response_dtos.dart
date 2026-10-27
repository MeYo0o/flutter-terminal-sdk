part of 'transaction_response.dart';

class ApprovalCode {
  final String value;
  final LanguageContent label;

  ApprovalCode({
    required this.value,
    required this.label,
  });

  factory ApprovalCode.fromJson(dynamic json) {
    return ApprovalCode(
      value: json['value'],
      label: LanguageContent.fromJson(json['label']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label.toJson(),
    };
  }
}

class LabelField2<T> {
  final T value;
  final LocalizationField label;

  LabelField2({required this.label, required this.value});

  factory LabelField2.fromJson(dynamic json) {
    return LabelField2(
      value: json['value'],
      label: LocalizationField.fromJson(json['label']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label.toJson(),
      'value': value,
    };
  }
}

class CardScheme {
  final LanguageContent? name;
  final String? id;

  CardScheme({
    required this.name,
    required this.id,
  });

  factory CardScheme.fromJson(dynamic json) {
    return CardScheme(
      name: LanguageContent.fromJson(json['name']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name?.toJson(),
      'id': id,
    };
  }
}

class TransactionType {
  final String? id;
  final LanguageContent? name;

  TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(dynamic json) {
    return TransactionType(
      id: json['id'],
      name: LanguageContent.fromJson(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
    };
  }
}
