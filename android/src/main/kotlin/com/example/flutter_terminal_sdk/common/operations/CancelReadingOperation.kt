package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import timber.log.Timber

class CancelReadingOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminalUUID = filter.getString("terminalUUID")
            ?: provider.connectedTerminalUUID
            ?: return response(
                ResponseHandler.error("MISSING_terminalUUID", "terminal uuid is required")
            )

        val activity = provider.activity
            ?: return response(ResponseHandler.error("NO_ACTIVITY", "Activity reference is null"))

        val terminal = provider.terminalSdk?.getTerminal(activity, terminalUUID)
            ?: return response(
                ResponseHandler.error("INVALID_TERMINAL", "No terminal found for UUID: $terminalUUID")
            )

        try {
            terminal.cancelReading()
            response(
                ResponseHandler.success(
                    "Reading cancelled",
                    mapOf("responseType" to "CancelReading")
                )
            )
        } catch (e: Exception) {
            Timber.tag("CancelReadingOperation").e("Cancel reading failed: ${e.message}")
            response(
                ResponseHandler.errorFromFailure(
                    "CANCEL_READING_FAILED",
                    e,
                    "Failed to cancel reading"
                )
            )
        }
    }
}
