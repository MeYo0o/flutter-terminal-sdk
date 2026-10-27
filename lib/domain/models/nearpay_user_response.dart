import '../../flutter_terminal_sdk.dart';
import 'data/TerminalList.dart';

class NearpayUser {
  final String? name;
  final String? email;
  final String? mobile;
  final String? userUUID;

  NearpayUser({
    this.name,
    this.email,
    this.mobile,
    this.userUUID,
  });

  factory NearpayUser.fromJson(Map<String, dynamic> json) {
    return NearpayUser(
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      userUUID: json['userUUID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'userUUID': userUUID,
    };
  }

  Future<TerminalList> getTerminalList(
    FlutterTerminalSdk sdk,
  ) async {
    if (userUUID == null || userUUID!.isEmpty) {
      throw NearpayException(
        "Cannot fetch terminals: userUUID is null or empty",
      );
    }

    return sdk.getTerminalList(userUUID!);
  }
}
