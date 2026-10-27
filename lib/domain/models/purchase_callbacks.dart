import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class PurchaseCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionPurchaseCallback? onTransactionPurchaseCompleted;

  PurchaseCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendTransactionFailure,
    this.onTransactionPurchaseCompleted,
  });
}
