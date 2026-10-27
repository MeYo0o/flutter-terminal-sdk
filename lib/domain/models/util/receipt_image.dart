import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_terminal_sdk/data/capabilities/operation_capabilities.dart';
import 'package:flutter_terminal_sdk/data/mappers/native/receipt_mapper.dart';
import 'package:flutter_terminal_sdk/data/sources/native/method_channel_native_source.dart';
import 'package:flutter_terminal_sdk/data/native/operation_status.dart';

Future<Uint8List> renderReceiptImage(
  Object receiptJson, {
  int? receiptWidth,
  int? fontSize,
  String receiptType = 'transaction',
}) async {
  requireOperationSupported('toImage');
  final receiptPayload = jsonEncode(receiptJson);

  try {
    final env = await MethodChannelNativeSource.instance.execute(
      'toImage',
      {
        "receiptWidth": receiptWidth,
        "fontSize": fontSize,
        "receiptPayload": receiptPayload,
        "receiptType": receiptType,
      },
    );
    assertEnvelopeSuccess(env, 'toImage',
        fallbackMessage: "Convert to image failed");
    return mapReceiptImage(env.data);
  } catch (e) {
    rethrow;
  }
}
