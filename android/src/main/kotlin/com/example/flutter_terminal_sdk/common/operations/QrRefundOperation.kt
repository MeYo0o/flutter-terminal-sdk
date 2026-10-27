package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.JSON_MAP_FAILED_MESSAGE
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.GeneratedQRCode
import io.nearpay.terminalsdk.data.dto.QrStatusResponse
import io.nearpay.terminalsdk.listeners.QrRefundListener
import io.nearpay.terminalsdk.listeners.failures.QrRefundFailure
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber
import java.util.UUID

class QrRefundOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val intentId = filter.getString("intentId")
            ?: return response(ResponseHandler.error("MISSING_INTENT_ID", "intentId is required"))

        val originalIntentId = filter.getString("originalIntentId")
            ?: filter.getString("originalIntentID")
            ?: return response(
                ResponseHandler.error(
                    "MISSING_ORIGINAL_INTENT_ID",
                    "originalIntentId is required"
                )
            )

        val requestId = filter.getString("requestId")
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: UUID.randomUUID().toString()

        val amount = filter.getString("amount")?.trim()?.takeIf { it.isNotEmpty() }

        val terminalUUID = filter.getString("uuid") ?: filter.getString("terminalUUID")
        val terminal = try {
            if (terminalUUID != null) {
                provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }
                    ?: provider.getCurrentTerminal()
            } else {
                provider.getCurrentTerminal()
            }
        } catch (e: Exception) {
            return response(
                ResponseHandler.errorFromFailure(
                    "TERMINAL_NOT_FOUND",
                    e,
                    "No connected terminal"
                )
            )
        }

        val listener = object : QrRefundListener {
            override fun onQrRefundQrCodeGenerated(qrCode: GeneratedQRCode) {
                val map = gson.toJsonMap(qrCode)
                if (map == null) {
                    sendQrEvent(requestId, "onQrRefundFailure", JSON_MAP_FAILED_MESSAGE, null)
                } else {
                    sendQrEvent(requestId, "onQrRefundQrCodeGenerated", null, map)
                }
            }

            override fun onQrRefundSuccess(response: QrStatusResponse) {
                val map = gson.toJsonMap(response)
                if (map == null) {
                    sendQrEvent(requestId, "onQrRefundFailure", JSON_MAP_FAILED_MESSAGE, null)
                } else {
                    sendQrEvent(requestId, "onQrRefundSuccess", null, map)
                }
            }

            override fun onQrRefundFailure(failure: QrRefundFailure) {
                val message = when (failure) {
                    is QrRefundFailure.GeneralFailure -> failure.message
                } ?: "QR refund failed"
                val envelope = ResponseHandler.errorFromFailure(
                    "QR_REFUND_FAILURE",
                    failure,
                    message
                )
                sendQrEvent(
                    requestId,
                    "onQrRefundFailure",
                    envelope["message"] as? String ?: message,
                    envelope
                )
            }

            override fun onNearpayException(nearPayException: NearpayException) {
                val envelope = ResponseHandler.errorFromFailure(
                    "QR_REFUND_FAILURE",
                    nearPayException,
                    nearPayException.message ?: "QR refund failed"
                )
                sendQrEvent(
                    requestId,
                    "onQrRefundFailure",
                    envelope["message"] as? String ?: "QR refund failed",
                    envelope
                )
            }
        }

        try {
            if (amount != null) {
                terminal.qrRefund(
                    intentUUID = originalIntentId,
                    refundUUID = intentId,
                    amount = amount,
                    qrRefundListener = listener
                )
            } else {
                terminal.qrRefund(
                    intentUUID = originalIntentId,
                    refundUUID = intentId,
                    qrRefundListener = listener
                )
            }
            response(
                ResponseHandler.success(
                    "QR refund started",
                    mapOf("requestId" to requestId, "responseType" to "QrRefund")
                )
            )
        } catch (e: Exception) {
            Timber.tag("QrRefundOperation").e(e, "QR refund failed")
            response(
                ResponseHandler.errorFromFailure(
                    "QR_REFUND_FAILED",
                    e,
                    e.message ?: "QR refund failed"
                )
            )
        }
    }

    private fun sendQrEvent(
        requestId: String,
        eventType: String,
        message: String?,
        data: Any?
    ) {
        val eventArgs = mutableMapOf<String, Any>(
            "requestId" to requestId,
            "type" to eventType
        )
        message?.let { eventArgs["message"] = it }
        data?.let { eventArgs["data"] = it }

        try {
            Handler(Looper.getMainLooper()).post {
                provider.methodChannel.invokeMethod("qrRefundEvent", eventArgs)
            }
        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send qrRefundEvent: $eventType for requestId: $requestId with error: ${e.message}"
            )
        }
    }
}
