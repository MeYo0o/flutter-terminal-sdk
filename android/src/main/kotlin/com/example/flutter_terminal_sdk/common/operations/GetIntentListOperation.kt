package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.IntentsListResponse
import io.nearpay.terminalsdk.listeners.GetIntentsListListener
import io.nearpay.terminalsdk.listeners.failures.GetIntentsListFailure
import timber.log.Timber

class GetIntentListOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val page = filter.getInt("page")
        val pageSize = filter.getInt("pageSize")
        val status = filter.getString("status")
        val isReconciled = filter.getBoolean("isReconciled")
        val startDate = filter.getString("startDate")
        val endDate = filter.getString("endDate")
        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        Timber.tag("GetTransactionListOperation").d(
            "terminalUUID: $terminalUUID, page: $page, pageSize: $pageSize, status: $status, isReconciled: $isReconciled, startDate: $startDate, endDate: $endDate, customerReferenceNumber: $customerReferenceNumber"
        )

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }

        terminal?.getIntentsList(
            page = page,
            pageSize = pageSize,
            status = status,
            isReconciled = isReconciled,
            startDate = startDate,
            endDate = endDate,
            customerReferenceNumber = customerReferenceNumber,
            getIntentsListListener = object : GetIntentsListListener {

                override fun onGetIntentsListFailure(error: GetIntentsListFailure) {
                    Timber.tag("GetTransactionListOperation")
                        .d("GetTransactionListFailure failed $error")
                    response(
                        ResponseHandler.errorFromFailure(
                            "GET_TRANSACTION_LIST_FAILURE", error, "Failed to get transaction list"
                        )
                    )
                }

                override fun onGetIntentsListSuccess(intentsList: IntentsListResponse) {
                    val map = gson.toJsonMap(intentsList)

                    Timber.tag("GetTransactionListOperation")
                        .d("GetTransactionListSuccess map $map")
                    if (map == null) {
                        response(
                            ResponseHandler.error(
                                "SERIALIZE_FAILED",
                                "Failed to serialize transaction list"
                            )
                        )
                    } else {
                        response(
                            ResponseHandler.success(
                                "Transaction list fetched successfully",
                                map
                            )
                        )
                    }
                }

            })
    }

}
