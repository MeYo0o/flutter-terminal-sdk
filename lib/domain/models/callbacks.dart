import 'package:flutter_terminal_sdk/domain/models/data/intent_details.dart';
import 'package:flutter_terminal_sdk/domain/models/data/dto/routing_full_response.dart';

import 'data/authorize_response.dart';
import 'data/capture_response.dart';
import 'data/generated_qr_code.dart';
import 'data/intent_response_turkey.dart';
import 'data/purchase_response.dart';
import 'data/qr_status_response.dart';
import 'data/refund_response.dart';
import 'data/void_authorization_response.dart';

typedef VoidCallback = void Function();
typedef InitializationCallback = void Function();
typedef StringCallback = void Function(String message);
typedef TransactionPurchaseCallback = void Function(PurchaseResponse response);
typedef RoutingLookupCallback = void Function(RoutingFullResponse response);
typedef TransactionPurchaseWithQRCallback = void Function(
    PurchaseResponse response);
typedef QRStatusCallback = void Function(QrStatusResponse response);
typedef QRGeneratedCallback = void Function(GeneratedQRCode response);
typedef TransactionRefundCallback = void Function(RefundResponse response);
typedef AuthorizedResponseCallback = void Function(AuthorizeResponse response);
typedef AuthorizedResponseWithTapCallback = void Function(
    CaptureResponse response);
typedef VoidAuthorizationWithTapCallback = void Function(
    VoidAuthorizationResponse response);
typedef PurchaseVoidResponseCallback = void Function(
    IntentResponseTurkey response);
typedef RefundVoidResponseCallback = void Function(
    IntentResponseTurkey response);
