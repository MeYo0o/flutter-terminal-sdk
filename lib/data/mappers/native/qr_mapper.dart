import 'package:flutter_terminal_sdk/domain/models/data/purchase_response.dart';

import '../../../domain/models/data/intent_details.dart';
import '../../../domain/models/data/generated_qr_code.dart';
import '../../../domain/models/data/qr_status_response.dart';
import 'mapper_utils.dart';

GeneratedQRCode mapGeneratedQrCode(Object? raw) =>
    GeneratedQRCode.fromJson(asResponseMap(raw));

QrStatusResponse mapQrStatusResponse(Object? raw) =>
    QrStatusResponse.fromJson(asResponseMap(raw));

IntentDetails mapQrIntentDetails(Object? raw) =>
    IntentDetails.fromJson(asResponseMap(raw));

PurchaseResponse mapQRPurchaseResponse(Object? raw) =>
    PurchaseResponse.fromJson(asResponseMap(raw));
