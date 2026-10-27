import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class RefundVoidCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onRefundVoidFailure;
  final RefundVoidResponseCallback? onRefundVoidCompleted;

  RefundVoidCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onRefundVoidFailure,
    this.onRefundVoidCompleted,
  });
}
