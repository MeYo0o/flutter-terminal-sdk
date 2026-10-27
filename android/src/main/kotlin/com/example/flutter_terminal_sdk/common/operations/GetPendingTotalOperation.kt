package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.listeners.PendingTotalListener
import io.nearpay.terminalsdk.listeners.failures.PendingTotalFailure
import timber.log.Timber

class GetPendingTotalOperation(provider: NearpayProvider) : BaseOperation(provider) {

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val terminal: Terminal =
            provider.terminalSdk?.getTerminal(provider.activity!!, terminalUUID)
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )
        Timber.d("Got Terminal successfully")
        try {
            terminal.getPendingTotal(pendingTotalListener = object :
                PendingTotalListener {

                override fun onPendingTotalFailure(pendingTotalFailure: PendingTotalFailure) {
                    Timber.tag("onPendingTotalFailure")
                        .d("GetPendingTotal failed $pendingTotalFailure")
                    response(
                        ResponseHandler.errorFromFailure(
                            "GetPendingTotal Failure",
                            pendingTotalFailure,
                            "Get pending total failed"
                        )
                    )
                }

                override fun onPendingTotalSuccess(pendingTotal: String) {
                    response(ResponseHandler.success("GetPendingTotal Success", pendingTotal))
                }
            })
        } catch (e: Exception) {
            response(ResponseHandler.errorFromFailure("GET_PENDING_TOTAL_FAILED", e, "Get pending total failed"))
        }
    }

}
