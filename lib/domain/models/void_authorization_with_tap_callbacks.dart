import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class VoidAuthorizationWithTapCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendTransactionFailure;
  final VoidAuthorizationWithTapCallback? onVoidAuthorizationWithTapCompleted;

  VoidAuthorizationWithTapCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendTransactionFailure,
    this.onVoidAuthorizationWithTapCompleted,
  });
}
