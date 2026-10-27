package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.JSON_MAP_FAILED_MESSAGE
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.RefundResponse
import io.nearpay.terminalsdk.listeners.RefundTransactionListener
import io.nearpay.terminalsdk.listeners.failures.RefundTransactionFailure
import timber.log.Timber

class RefundWithoutTapOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val intentUUID = filter.getString("intentUUID") ?: return response(
            ResponseHandler.error("MISSING_TRANSACTION_UUID", "Transaction UUID is required")
        )
        val refundUUID = filter.getString("refundUUID")
            ?: filter.getString("refundUuid") ?: return response(
            ResponseHandler.error("MISSING_REFUND_UUID", "Refund UUID is required")
        )

        val customerReferenceNumber = filter.getString("customerReferenceNumber")
        val amount = filter.getLong("amount")

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }

        terminal?.refundWithoutTap(
            intentUUID = intentUUID,
            refundUUID = refundUUID,
            customerReferenceNumber = customerReferenceNumber,
            amount = amount,
            refundTransactionListener = object :
                RefundTransactionListener {
                override fun onRefundTransactionCompleted(refundResponse: RefundResponse) {
                    Timber.tag("RefundWithoutTapOperation")
                        .d("onRefundTransactionCompleted $refundResponse")
                    val map = gson.toJsonMap(refundResponse)
                    if (map == null) {
                        sendRefundEvent(
                            intentUUID,
                            "sendTransactionFailure",
                            JSON_MAP_FAILED_MESSAGE,
                            null
                        )
                    } else {
                        sendRefundEvent(
                            intentUUID,
                            "sendRefundTransactionCompleted",
                            null,
                            map
                        )
                    }
                }

                override fun onRefundTransactionFailure(refundTransactionFailure: RefundTransactionFailure) {
                    Timber.tag("RefundWithoutTapOperation")
                        .d("onRefundTransactionFailure $refundTransactionFailure")
                    sendRefundEvent(
                        intentUUID,
                        "sendTransactionFailure",
                        ResponseHandler.eventMessage(refundTransactionFailure),
                        null
                    )
                }
            })
        response(ResponseHandler.success("Refund without tap operation started"))
    }

    private fun sendRefundEvent(
        intentUUID: String,
        eventType: String,
        message: String?,
        data: Any?
    ) {
        val eventArgs = mutableMapOf<String, Any>(
            "intentUUID" to intentUUID,
            "type" to eventType
        )
        message?.let { eventArgs["message"] = it }
        data?.let { eventArgs["data"] = it }

        try {
            provider.methodChannel.invokeMethod("refundEvent", eventArgs)
        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send refund event: $eventType for intentUUID: $intentUUID"
            )
        }
    }
}
