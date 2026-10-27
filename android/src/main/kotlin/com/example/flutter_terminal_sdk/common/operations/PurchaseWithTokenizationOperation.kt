package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.JSON_MAP_FAILED_MESSAGE
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.PurchaseResponse
import io.nearpay.terminalsdk.listeners.SendTransactionListener
import io.nearpay.terminalsdk.listeners.failures.SendTransactionFailure
import timber.log.Timber

class PurchaseWithTokenizationOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val amount = filter.getLong("amount")
            ?: return response(ResponseHandler.error("MISSING_AMOUNT", "Amount is required"))

        val intentUUID = filter.getString("intentUUID")
            ?: return response(
                ResponseHandler.error("MISSING_INTENT_UUID", "intent UUID is required")
            )

        val tokenizationID = filter.getString("tokenizationID")
            ?: filter.getString("tokenizationId")
            ?: return response(
                ResponseHandler.error("MISSING_TOKENIZATION_ID", "Tokenization id is required")
            )

        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        invalidWholeNumber(filter, "surchargeAmount", "INVALID_SURCHARGE_AMOUNT")
            ?.let { return response(it) }
        invalidWholeNumber(filter, "taxPercentage", "INVALID_TAX_PERCENTAGE")
            ?.let { return response(it) }

        val surchargeAmount = filter.getLong("surchargeAmount")
        val taxPercentage = filter.getLong("taxPercentage")

        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        try {
            terminal.purchaseWithTokenization(
                amount = amount.toString(),
                tokenizationID = tokenizationID,
                intentUUID = intentUUID,
                customerReferenceNumber = customerReferenceNumber,
                surchargeAmount = surchargeAmount,
                taxPercentage = taxPercentage,
                sendTransactionListener = object : SendTransactionListener {
                    override fun onSendTransactionCompleted(transactionResponse: PurchaseResponse) {
                        val map = gson.toJsonMap(transactionResponse)
                        if (map == null) {
                            sendPurchaseEvent(
                                intentUUID,
                                "sendTransactionFailure",
                                JSON_MAP_FAILED_MESSAGE,
                                null
                            )
                        } else {
                            sendPurchaseEvent(
                                intentUUID,
                                "sendPurchaseTransactionCompleted",
                                null,
                                map
                            )
                        }
                    }

                    override fun onSendTransactionFailure(sendTransactionFailure: SendTransactionFailure) {
                        sendPurchaseEvent(
                            intentUUID,
                            "sendTransactionFailure",
                            ResponseHandler.eventMessage(sendTransactionFailure),
                            null
                        )
                    }
                }
            )
            response(ResponseHandler.success("Purchase with tokenization operation started"))
        } catch (e: Exception) {
            Timber.tag("PurchaseWithTokenizationOperation").e(e, "Purchase with tokenization failed")
            response(
                ResponseHandler.errorFromFailure(
                    "PURCHASE_WITH_TOKENIZATION_FAILED",
                    e,
                    "Purchase with tokenization failed"
                )
            )
        }
    }

    private fun sendPurchaseEvent(
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
            Handler(Looper.getMainLooper()).post {
                provider.methodChannel.invokeMethod("purchaseEvent", eventArgs)
            }
        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send purchase event: $eventType for intentUUID: $intentUUID with error: ${e.message}"
            )
        }
    }
}
