//@kotlinx.serialization.Serializable public final data class RoutingBin public constructor(bin: kotlin.String? = COMPILED_CODE, issuerId: kotlin.String? = COMPILED_CODE, brand: kotlin.String? = COMPILED_CODE, cardType: kotlin.String? = COMPILED_CODE) {

class RoutingBin {
  final String? bin;
  final String? issuerId;
  final String? brand;
  final String? cardType;

  RoutingBin({
    this.bin,
    this.issuerId,
    this.brand,
    this.cardType,
  });

  factory RoutingBin.fromJson(Map<dynamic, dynamic> json) {
    return RoutingBin(
      bin: json['bin'],
      issuerId: json['issuerId'],
      brand: json['brand'],
      cardType: json['cardType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bin': bin,
      'issuerId': issuerId,
      'brand': brand,
      'cardType': cardType,
    };
  }
}
