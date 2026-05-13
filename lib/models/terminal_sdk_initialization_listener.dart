import 'callbacks.dart';
import 'card_reader_callbacks.dart';

class TerminalSDKInitializationListener {
  final StringCallback? onInitializationFailure;
  final InitializationCallback? onInitializationSuccess;

  TerminalSDKInitializationListener({
    this.onInitializationFailure,
    this.onInitializationSuccess,
  });
}