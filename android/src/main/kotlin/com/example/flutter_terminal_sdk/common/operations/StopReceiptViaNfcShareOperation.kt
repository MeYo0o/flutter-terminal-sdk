package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class StopReceiptViaNfcShareOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        try {
            val terminal = provider.getCurrentTerminal()
            terminal.stopReceiptViaNfcShare()
            response(
                ResponseHandler.success(
                    "NFC receipt share stopped",
                    mapOf("responseType" to "StopReceiptViaNfcShare"),
                )
            )
        } catch (e: Exception) {
            response(
                ResponseHandler.error(
                    "STOP_RECEIPT_VIA_NFC_SHARE_FAILED",
                    e.message ?: "Failed to stop NFC receipt share",
                )
            )
        }
    }
}
