import '../util/json_pick.dart';
import 'detail_item.dart';

class Details {
  final DetailItem total;
  final DetailItem purchase;
  final DetailItem purchaseReversal;
  final DetailItem refund;
  final DetailItem refundReversal;

  Details({
    required this.total,
    required this.purchase,
    required this.purchaseReversal,
    required this.refund,
    required this.refundReversal,
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      total: DetailItem.fromJson(json['total'] as Map<String, dynamic>),
      purchase: DetailItem.fromJson(json['purchase'] as Map<String, dynamic>),
      purchaseReversal: DetailItem.fromJson(
          pickKey(json, ['purchaseReversal', 'purchase_reversal'])
              as Map<String, dynamic>),
      refund: DetailItem.fromJson(json['refund'] as Map<String, dynamic>),
      refundReversal: DetailItem.fromJson(
          pickKey(json, ['refundReversal', 'refund_reversal'])
              as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total.toJson(),
        'purchase': purchase.toJson(),
        'purchase_reversal': purchaseReversal.toJson(),
        'refund': refund.toJson(),
        'refund_reversal': refundReversal.toJson(),
      };
}
