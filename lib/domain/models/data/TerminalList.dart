import '../intents_list_response.dart';
import '../terminal_connection_response.dart';

class TerminalList {
  final List<TerminalConnectionModel> terminals;
  final Pagination pagination;

  const TerminalList({
    required this.terminals,
    required this.pagination,
  });

  factory TerminalList.fromJson(dynamic json) {
    final data = json as Map<String, dynamic>;
    Pagination paginationInfo =
        Pagination.fromJson(data['pagination'] as Map<String, dynamic>);
    final terminals = (data['terminals'] as List<dynamic>).map((terminalJson) {
      return TerminalConnectionModel.fromJson(
        terminalJson as Map<String, dynamic>,
      );
    }).toList();
    return TerminalList(
      terminals: terminals,
      pagination: paginationInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terminals': terminals.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
