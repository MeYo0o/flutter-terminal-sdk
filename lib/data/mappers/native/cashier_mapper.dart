import '../../../domain/models/data/authenticator_response.dart';
import '../../../domain/models/data/cashier/invoice.dart';
import '../../../domain/models/data/cashier/product.dart';
import 'mapper_utils.dart';

InvoiceResponse mapInvoiceResponse(Object? raw) =>
    InvoiceResponse.fromJson(asResponseMap(raw));

InvoiceListResponse mapInvoiceListResponse(Object? raw) =>
    InvoiceListResponse.fromJson(asResponseMap(raw));

InvoiceDetails mapInvoiceDetails(Object? raw) =>
    InvoiceDetails.fromJson(asResponseMap(raw));

CashierProductResponse mapProductResponse(Object? raw) =>
    CashierProductResponse.fromJson(asResponseMap(raw));

CashierProductsListResponse mapProductsListResponse(Object? raw) =>
    CashierProductsListResponse.fromJson(asResponseMap(raw));

AuthenticatorResponse mapAuthenticatorResponse(Object? raw) =>
    AuthenticatorResponse.fromJson(asResponseMap(raw));
