package com.example.flutter_terminal_sdk.common.operations

import io.nearpay.terminalsdk.nfc.ReceiptNfcShareFailure

object NfcShareFailureMapper {
    fun toMap(failure: ReceiptNfcShareFailure): Map<String, Any?> {
        return when (failure) {
            is ReceiptNfcShareFailure.InvalidUrl -> mapOf(
                "type" to "InvalidUrl",
                "message" to failure.message,
            )

            is ReceiptNfcShareFailure.UnsupportedDevice -> mapOf(
                "type" to "UnsupportedDevice",
            )

            is ReceiptNfcShareFailure.NfcDisabled -> mapOf(
                "type" to "NfcDisabled",
            )

            is ReceiptNfcShareFailure.GeneralFailure -> mapOf(
                "type" to "GeneralFailure",
                "message" to failure.message,
            )
        }
    }
}
