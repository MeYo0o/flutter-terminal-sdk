import 'callbacks.dart';
import 'card_reader_callbacks.dart';
import 'linking_callbacks.dart';

class AuthorizedCallbacks {
  final CardReaderCallbacks? cardReaderCallbacks;
  final LinkingCallbacks? linkingCallbacks;
  final StringCallback? onSendTransactionFailure;
  final AuthorizedResponseCallback? onSendAuthorizedCompleted;

  AuthorizedCallbacks({
    this.cardReaderCallbacks,
    this.linkingCallbacks,
    this.onSendTransactionFailure,
    this.onSendAuthorizedCompleted,
  });
}
