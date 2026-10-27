package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class SupportsReceiptViaNfcOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        try {
            val terminal = provider.getCurrentTerminal()
            val requireEnabled = filter.getBoolean("requireEnabled") ?: true
            val supported = terminal.supportsReceiptViaNfc(requireEnabled)
            response(
                ResponseHandler.success(
                    "NFC receipt share support checked",
                    mapOf("supported" to supported),
                )
            )
        } catch (e: Exception) {
            response(
                ResponseHandler.error(
                    "SUPPORTS_RECEIPT_VIA_NFC_FAILED",
                    e.message ?: "Failed to check NFC receipt share support",
                )
            )
        }
    }
}
