//@kotlinx.serialization.Serializable public final data class InstallmentOption public constructor(installmentCount: kotlin.Int, installmentPercentage: kotlin.Double, paymentPlan: kotlin.String, totalCalculatedAmount: kotlin.Double)

class InstallmentOption {
  final int installmentCount;
  final double installmentPercentage;
  final String paymentPlan;
  final double totalCalculatedAmount;

  InstallmentOption({
    required this.installmentCount,
    required this.installmentPercentage,
    required this.paymentPlan,
    required this.totalCalculatedAmount,
  });

  factory InstallmentOption.fromJson(Map<dynamic, dynamic> json) {
    return InstallmentOption(
      installmentCount: (json['installmentCount'] as num).toInt(),
      installmentPercentage: (json['installmentPercentage'] as num).toDouble(),
      paymentPlan: json['paymentPlan'],
      totalCalculatedAmount: (json['totalCalculatedAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installmentCount': installmentCount,
      'installmentPercentage': installmentPercentage,
      'paymentPlan': paymentPlan,
      'totalCalculatedAmount': totalCalculatedAmount,
    };
  }
}
