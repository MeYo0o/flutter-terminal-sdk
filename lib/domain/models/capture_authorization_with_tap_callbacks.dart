import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class CaptureAuthorizationWithTapCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendTransactionFailure;
  final AuthorizedResponseWithTapCallback? onAuthorizedResponseWithTapCompleted;

  CaptureAuthorizationWithTapCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendTransactionFailure,
    this.onAuthorizedResponseWithTapCompleted,
  });
}
