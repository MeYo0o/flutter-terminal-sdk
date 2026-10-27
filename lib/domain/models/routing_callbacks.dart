import 'callbacks.dart';
import 'card_reader_callbacks.dart';

class RoutingLookupCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final StringCallback? onSendTransactionFailure;
  final RoutingLookupCallback? onRoutingLookupCompleted;

  RoutingLookupCallbacks({
    this.cardReaderCallbacks,
    this.onSendTransactionFailure,
    this.onRoutingLookupCompleted,
  });
}
