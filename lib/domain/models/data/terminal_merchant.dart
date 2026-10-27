// terminal_merchant.dart
import '../util/json_pick.dart';
import 'dto/LocalizationField.dart';

class TerminalMerchant {
  final String id;
  final LocalizationField name;
  final String? createdAt;

  const TerminalMerchant({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory TerminalMerchant.fromJson(Map<String, dynamic> json) {
    return TerminalMerchant(
      id: json['id'] as String,
      name: LocalizationField.fromJson(json['name'] as Map<String, dynamic>),
      createdAt: pickKey(json, ['createdAt', 'created_at']) as String?,
    );
  }

  TerminalMerchant copyWith({
    String? id,
    LocalizationField? name,
    String? createdAt,
  }) {
    return TerminalMerchant(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'createdAt': createdAt,
    };
  }

  @override
  String toString() =>
      'TerminalMerchant(id: $id, name: $name, createdAt: $createdAt)';
}
