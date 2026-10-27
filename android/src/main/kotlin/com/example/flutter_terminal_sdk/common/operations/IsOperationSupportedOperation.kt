package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.TerminalOperation

class IsOperationSupportedOperation(provider: NearpayProvider) : BaseOperation(provider) {

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val settle = createSettler(response)

        val terminalUUID = filter.getString("terminalUUID")
            ?: return settle(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val requested = filter.getStringAnyOf("operation", "operationName")
            ?: return settle(
                ResponseHandler.error("MISSING_OPERATION", "operation is required")
            )

        val operation = resolveOperation(requested)
        if (operation == null && UNGATED_OPERATIONS.none { it.equals(requested, ignoreCase = true) }) {
            return settle(
                ResponseHandler.error("UNKNOWN_OPERATION", "Unknown operation: $requested")
            )
        }

        val terminal: Terminal =
            provider.terminalSdk?.getTerminal(provider.activity!!, terminalUUID)
                ?: return settle(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        try {
            val supported = operation?.let { terminal.isOperationSupported(it) } ?: true
            settle(
                ResponseHandler.success(
                    "Operation support resolved",
                    mapOf(
                        "operation" to requested,
                        "supported" to supported
                    )
                )
            )
        } catch (e: Exception) {
            settle(
                ResponseHandler.errorFromFailure(
                    "IS_OPERATION_SUPPORTED_FAILED",
                    e,
                    "Failed to resolve operation support"
                )
            )
        }
    }

    private fun resolveOperation(value: String): TerminalOperation? =
        TerminalOperation.values().firstOrNull {
            it.operationName.equals(value, ignoreCase = true) ||
                it.name.equals(value, ignoreCase = true)
        }

    private companion object {
        private val UNGATED_OPERATIONS = listOf("batchCapture", "cancelTransaction")
    }
}
