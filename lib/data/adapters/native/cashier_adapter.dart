import '../../../domain/models/data/authenticator_response.dart';
import '../../../domain/models/data/cashier/invoice.dart';
import '../../../domain/models/data/cashier/product.dart';
import '../../../domain/models/nfc_share_callbacks.dart';
import '../../../errors/errors.dart';
import '../../mappers/native/cashier_mapper.dart';
import 'adapter_utils.dart';

InvoiceResponse adaptCreateInvoiceResult(String operation, Object? data) =>
    mapInvoiceResponse(unwrapForCurrentPlatform(operation, data));

InvoiceListResponse adaptInvoiceListResult(String operation, Object? data) =>
    mapInvoiceListResponse(unwrapForCurrentPlatform(operation, data));

InvoiceDetails adaptInvoiceDetailsResult(String operation, Object? data) =>
    mapInvoiceDetails(unwrapForCurrentPlatform(operation, data));

CashierProductResponse adaptCreateProductResult(
        String operation, Object? data) =>
    mapProductResponse(unwrapForCurrentPlatform(operation, data));

CashierProductsListResponse adaptGetAllProductsResult(
        String operation, Object? data) =>
    mapProductsListResponse(unwrapForCurrentPlatform(operation, data));

CashierProductResponse adaptGetProductResult(String operation, Object? data) =>
    mapProductResponse(unwrapForCurrentPlatform(operation, data));

AuthenticatorResponse adaptAuthenticatorResult(
        String operation, Object? data) =>
    mapAuthenticatorResponse(unwrapForCurrentPlatform(operation, data));

bool adaptSupportsReceiptViaNfcResult(String operation, Object? data) {
  final payload = unwrapForCurrentPlatform(operation, data);
  if (payload is! Map) {
    throw NearpayException('$operation returned invalid payload');
  }
  return payload['supported'] == true;
}

NfcShareStartResult adaptNfcShareStartResult(String operation, Object? data) {
  final payload = unwrapForCurrentPlatform(operation, data);
  if (payload is! Map) {
    throw NearpayException('$operation returned invalid payload');
  }
  final sessionId = payload['sessionId']?.toString().trim() ?? '';
  if (sessionId.isEmpty) {
    throw NearpayException('$operation returned invalid sessionId');
  }
  return NfcShareStartResult(
    started: payload['started'] == true,
    sessionId: sessionId,
  );
}
