package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import io.nearpay.terminalsdk.nfc.ReceiptNfcShareFailure
import timber.log.Timber

object NfcShareEventEmitter {
    fun emit(
        provider: NearpayProvider,
        terminalUUID: String,
        sessionId: String,
        type: String,
        failure: ReceiptNfcShareFailure? = null,
    ) {
        val eventArgs = mutableMapOf<String, Any>(
            "terminalUUID" to terminalUUID,
            "sessionId" to sessionId,
            "type" to type,
        )
        failure?.let { eventArgs["data"] = NfcShareFailureMapper.toMap(it) }

        try {
            provider.methodChannel.invokeMethod("nfcShareEvent", eventArgs)
        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send nfcShareEvent: $type for sessionId: $sessionId",
            )
        }
    }
}
