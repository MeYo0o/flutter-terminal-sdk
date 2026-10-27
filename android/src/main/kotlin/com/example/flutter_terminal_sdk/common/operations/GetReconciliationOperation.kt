package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.ReconciliationResponse
import io.nearpay.terminalsdk.listeners.GetReconciliationListener
import io.nearpay.terminalsdk.listeners.failures.GetReconciliationFailure
import timber.log.Timber

class GetReconciliationOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val uuid = filter.getString("uuid") ?: return response(
            ResponseHandler.error(
                "MISSING_UUID", "Reconciliation uuid is required"
            )
        )

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }

        terminal?.getReconciliation(
            uuid = uuid, getReconciliationListener = object : GetReconciliationListener {
                override fun onGetReconciliationSuccess(reconciliationResponse: ReconciliationResponse) {
                    val map = gson.toJsonMap(reconciliationResponse)
                    if (map == null) {
                        response(
                            ResponseHandler.error(
                                "SERIALIZE_FAILED",
                                "Failed to serialize reconciliation"
                            )
                        )
                    } else {
                        response(ResponseHandler.success("Get Reconciliation Success", map))
                    }

                }

                override fun onGetReconciliationFailure(error: GetReconciliationFailure) {
                    Timber.tag("handleReadCard").d("GetReconciliation failed $error")
                    response(ResponseHandler.errorFromFailure("Get Reconciliation Failure", error, "Failed to get reconciliation"))

                }
            })
    }

}