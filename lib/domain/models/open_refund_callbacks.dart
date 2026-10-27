import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class OpenRefundCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionRefundCallback? onTransactionOpenRefundCompleted;

  OpenRefundCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendTransactionFailure,
    this.onTransactionOpenRefundCompleted,
  });
}
