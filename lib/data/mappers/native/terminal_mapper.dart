import '../../../errors/errors.dart';
import '../../../domain/models/data/TerminalList.dart';
import '../../../domain/models/data/terminal_config.dart';
import '../../../domain/models/terminal_response.dart';
import 'mapper_utils.dart';

TerminalModel mapTerminalModel(Object? raw) =>
    TerminalModel.fromJson(asResponseMap(raw));

TerminalList mapTerminalList(Object? raw) =>
    TerminalList.fromJson(asResponseMap(raw));

TerminalConfig mapTerminalConfig(Object? raw) {
  if (raw is! Map) {
    throw NearpayException('Invalid terminal config payload');
  }
  return TerminalConfig.fromJson(Map<String, dynamic>.from(raw));
}
