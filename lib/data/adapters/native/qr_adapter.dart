import '../../../domain/models/data/intent_details.dart';
import '../../../domain/models/data/generated_qr_code.dart';
import '../../../domain/models/data/purchase_response.dart';
import '../../../domain/models/data/qr_status_response.dart';
import '../../mappers/native/qr_mapper.dart';
import 'adapter_utils.dart';

GeneratedQRCode adaptGeneratedQrCodeResult(String operation, Object? data) =>
    mapGeneratedQrCode(unwrapForCurrentPlatform(operation, data));

QrStatusResponse adaptQrStatusResult(String operation, Object? data) =>
    mapQrStatusResponse(unwrapForCurrentPlatform(operation, data));

IntentDetails adaptQrIntentDetailsResult(String operation, Object? data) =>
    mapQrIntentDetails(unwrapForCurrentPlatform(operation, data));

PurchaseResponse adaptQRPurchaseResponseResult(String operation, Object? data) =>
    mapQRPurchaseResponse(unwrapForCurrentPlatform(operation, data));
