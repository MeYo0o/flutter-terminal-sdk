package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.nfc.ReceiptNfcShareFailure
import io.nearpay.terminalsdk.nfc.ReceiptNfcShareListener

class ShareReceiptViaNfcOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val url = filter.getString("url")
            ?: return response(ResponseHandler.error("MISSING_URL", "shareReceiptViaNfc requires url"))

        val sessionId = filter.getString("sessionId")
            ?: return response(
                ResponseHandler.error("MISSING_SESSION_ID", "shareReceiptViaNfc requires sessionId")
            )

        val terminalUUID = filter.getString("terminalUUID")?.trim().orEmpty()

        val timeoutMillis = filter.getLong("timeoutMillis") ?: 20_000L

        try {
            val terminal = provider.getCurrentTerminal()
            runCatching { terminal.stopReceiptViaNfcShare() }
            val started = terminal.shareReceiptViaNfc(
                receiptUrl = url,
                timeoutMillis = timeoutMillis,
                listener = nfcShareListener(terminalUUID, sessionId),
            )
            response(
                ResponseHandler.success(
                    if (started) "NFC receipt share started" else "NFC receipt share did not start",
                    mapOf("started" to started, "sessionId" to sessionId),
                )
            )
        } catch (e: Exception) {
            response(
                ResponseHandler.error(
                    "SHARE_RECEIPT_VIA_NFC_FAILED",
                    e.message ?: "Failed to share receipt via NFC",
                )
            )
        }
    }

    private fun nfcShareListener(
        terminalUUID: String,
        sessionId: String,
    ): ReceiptNfcShareListener = object : ReceiptNfcShareListener {
        override fun onStarted() {
            NfcShareEventEmitter.emit(provider, terminalUUID, sessionId, "onStarted")
        }

        override fun onShared() {
            NfcShareEventEmitter.emit(provider, terminalUUID, sessionId, "onShared")
        }

        override fun onStopped() {
            NfcShareEventEmitter.emit(provider, terminalUUID, sessionId, "onStopped")
        }

        override fun onFailure(error: ReceiptNfcShareFailure) {
            NfcShareEventEmitter.emit(provider, terminalUUID, sessionId, "onFailure", error)
        }
    }
}
