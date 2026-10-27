package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.ReconciliationReceiptsResponse
import io.nearpay.terminalsdk.listeners.ReconcileListener
import io.nearpay.terminalsdk.listeners.failures.ReconcileFailure
import timber.log.Timber

class ReconcileOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

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
            terminal.reconcile(reconcileListener = object :
                ReconcileListener {

                override fun onReconcileFailure(reconcileFailure: ReconcileFailure) {
                    Timber.tag("onReconcileFailure").d("Reconcile failed $reconcileFailure")
                    response(
                        ResponseHandler.errorFromFailure(
                            "Reconcile Failure",
                            reconcileFailure,
                            "Reconcile failed"
                        )
                    )
                }

                override fun onReconcileCompleted(reconciliationReceiptsResponse: ReconciliationReceiptsResponse) {
                    val map = gson.toJsonMap(reconciliationReceiptsResponse)
                    if (map == null) {
                        response(
                            ResponseHandler.error(
                                "SERIALIZE_FAILED",
                                "Failed to serialize reconcile response"
                            )
                        )
                    } else {
                        response(ResponseHandler.success("Reconcile Success", map))
                    }
                }
            })
        } catch (e: Exception) {
            response(ResponseHandler.errorFromFailure("RECONCILE_FAILED", e, "Reconcile failed"))
        }
    }

}
