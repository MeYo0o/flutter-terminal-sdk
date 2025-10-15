import 'package:flutter_terminal_sdk/models/data/dto/transaction_response_turkey.dart';
import 'package:flutter_terminal_sdk/models/data/purchase_response.dart';
import 'package:flutter_terminal_sdk/models/data/transaction_response.dart';
import 'package:flutter_terminal_sdk/models/data/authorized_receipt.dart';

import 'data/authorize_response.dart';
import 'data/intent_response_turkey.dart';
import 'data/refund_response.dart';

typedef VoidCallback = void Function();
typedef StringCallback = void Function(String message);
typedef TransactionPurchaseCallback = void Function(PurchaseResponse response);
typedef TransactionRefundCallback = void Function(RefundResponse response);
typedef AuthorizedResponseCallback = void Function(AuthorizeResponse response);
typedef PurchaseVoidResponseCallback = void Function(
    IntentResponseTurkey response);
typedef RefundVoidResponseCallback = void Function(
    IntentResponseTurkey response);
