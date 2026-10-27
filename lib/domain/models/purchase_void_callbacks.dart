import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class PurchaseVoidCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendPurchaseVoidFailure;
  final PurchaseVoidResponseCallback? onSendPurchaseVoidCompleted;

  PurchaseVoidCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendPurchaseVoidFailure,
    this.onSendPurchaseVoidCompleted,
  });
}
