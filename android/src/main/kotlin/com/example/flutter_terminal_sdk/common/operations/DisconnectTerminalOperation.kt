package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.softpos.library.DisconnectCallBack
import io.nearpay.softpos.utils.NearPayError
import timber.log.Timber
import java.util.concurrent.atomic.AtomicBoolean

class DisconnectTerminalOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminal = try {
            provider.getCurrentTerminal()
        } catch (e: Exception) {
            return response(
                ResponseHandler.error("NO_TERMINAL", e.message ?: "No terminal selected")
            )
        }

        val terminalUUID = terminal.terminalUUID
        val settled = AtomicBoolean(false)

        try {
            terminal.disconnectTerminal(object : DisconnectCallBack {
                override fun onSuccess() {
                    if (!settled.compareAndSet(false, true)) return
                    runCatching { terminal.stopReceiptViaNfcShare() }
                    provider.clearCurrentTerminal()
                    response(
                        ResponseHandler.success(
                            "Terminal disconnected successfully",
                            mapOf(
                                "disconnected" to true,
                                "terminalUUID" to terminalUUID
                            )
                        )
                    )
                }

                override fun onFailure(error: NearPayError) {
                    if (!settled.compareAndSet(false, true)) return
                    Timber.tag("DisconnectTerminalOperation").e("Disconnect failed: $error")
                    response(
                        ResponseHandler.errorFromFailure(
                            "DISCONNECT_TERMINAL_FAILURE",
                            error,
                            "Failed to disconnect terminal"
                        )
                    )
                }
            })
        } catch (e: Exception) {
            response(
                ResponseHandler.errorFromFailure(
                    "DISCONNECT_TERMINAL_FAILED",
                    e,
                    "Failed to disconnect terminal"
                )
            )
        }
    }
}
