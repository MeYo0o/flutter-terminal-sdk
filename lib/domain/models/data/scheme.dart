import 'package:flutter_terminal_sdk/domain/models/data/pos_host_details.dart';

import '../util/json_pick.dart';
import 'label_value.dart';

class Scheme {
  final LabelValue<String> name;
  final PosHostDetails pos;
  final PosHostDetails host;
  final bool isBalanced;

  Scheme({
    required this.name,
    required this.pos,
    required this.host,
    required this.isBalanced,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      name: LabelValue.stringFromJson(json['name'] as Map<String, dynamic>),
      pos: PosHostDetails.fromJson(json['pos'] as Map<String, dynamic>),
      host: PosHostDetails.fromJson(json['host'] as Map<String, dynamic>),
      isBalanced: toBoolSafe(pickKey(json, ['isBalanced', 'is_balanced'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name.toJson(),
        'pos': pos.toJson(),
        'host': host.toJson(),
        'is_balanced': isBalanced,
      };
}
