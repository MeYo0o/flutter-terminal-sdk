import '../../../domain/models/data/TerminalList.dart';
import '../../../domain/models/data/terminal_config.dart';
import '../../../domain/models/terminal_response.dart';
import '../../mappers/native/terminal_mapper.dart';
import 'adapter_utils.dart';

TerminalModel adaptTerminalModelResult(String operation, Object? data) =>
    mapTerminalModel(unwrapForCurrentPlatform(operation, data));

TerminalList adaptTerminalListResult(String operation, Object? data) =>
    mapTerminalList(unwrapForCurrentPlatform(operation, data));

TerminalConfig adaptTerminalConfigResult(String operation, Object? data) =>
    mapTerminalConfig(unwrapForCurrentPlatform(operation, data));
