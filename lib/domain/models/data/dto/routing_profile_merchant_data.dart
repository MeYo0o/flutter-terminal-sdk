class RoutingProfileMerchantData {
  final String? businessName;
  final String? taxOfficeName;
  final String? businessAddress;
  final String? businessProvince;
  final String? businessTelephone;
  final String? acquirerBusinessNo;
  final String? taxIdentificationNo;
  final String? merchantCategoryCode;

  RoutingProfileMerchantData({
    this.businessName,
    this.taxOfficeName,
    this.businessAddress,
    this.businessProvince,
    this.businessTelephone,
    this.acquirerBusinessNo,
    this.taxIdentificationNo,
    this.merchantCategoryCode,
  });

  factory RoutingProfileMerchantData.fromJson(Map<String, dynamic> json) {
    return RoutingProfileMerchantData(
      businessName: json['businessName'],
      taxOfficeName: json['taxOfficeName'],
      businessAddress: json['businessAddress'],
      businessProvince: json['businessProvince'],
      businessTelephone: json['businessTelephone'],
      acquirerBusinessNo: json['acquirerBusinessNo'],
      taxIdentificationNo: json['taxIdentificationNo'],
      merchantCategoryCode: json['merchantCategoryCode'],
    );
  }

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'taxOfficeName': taxOfficeName,
        'businessAddress': businessAddress,
        'businessProvince': businessProvince,
        'businessTelephone': businessTelephone,
        'acquirerBusinessNo': acquirerBusinessNo,
        'taxIdentificationNo': taxIdentificationNo,
        'merchantCategoryCode': merchantCategoryCode,
      };
}
