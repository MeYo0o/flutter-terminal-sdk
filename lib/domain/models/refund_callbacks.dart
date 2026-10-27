import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class RefundCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendTransactionFailure;
  final TransactionRefundCallback? onTransactionRefundCompleted;

  RefundCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendTransactionFailure,
    this.onTransactionRefundCompleted,
  });
}
