import 'dart:convert';

import '../errors/errors.dart';

Future<Map<String, dynamic>> callAndReturnMapResponse(
  String methodName,
  dynamic data,
  dynamic channel,
) async {
  final tempResponse = await channel.invokeMethod(methodName, data);
  return jsonDecode(jsonEncode(tempResponse));
}
