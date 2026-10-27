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
import io.nearpay.terminalsdk.data.dto.Location
import io.nearpay.terminalsdk.data.dto.QrStatusResponse
import io.nearpay.terminalsdk.listeners.QrVoidListener
import io.nearpay.terminalsdk.listeners.failures.QrVoidFailure
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber
import java.util.UUID

class QrVoidOperation(provider: NearpayProvider) : BaseOperation(provider) {
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

        val lat = filter.getDouble("lat")
        val long = filter.getDouble("long")
        val isLocationFromMock = filter.getBoolean("isLocationFromMock")
        val location =
            if (lat != null && long != null) {
                Location(long = long, lat = lat, isLocationFromMock = isLocationFromMock)
            } else {
                null
            }

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

        val listener = object : QrVoidListener {
            override fun onQrVoidQrCodeGenerated(qrCode: GeneratedQRCode) {
                val map = gson.toJsonMap(qrCode)
                if (map == null) {
                    sendQrEvent(requestId, "onQrVoidFailure", JSON_MAP_FAILED_MESSAGE, null)
                } else {
                    sendQrEvent(requestId, "onQrVoidQrCodeGenerated", null, map)
                }
            }

            override fun onQrVoidSuccess(status: QrStatusResponse) {
                val map = gson.toJsonMap(status)
                if (map == null) {
                    sendQrEvent(requestId, "onQrVoidFailure", JSON_MAP_FAILED_MESSAGE, null)
                } else {
                    sendQrEvent(requestId, "onQrVoidSuccess", null, map)
                }
            }

            override fun onQrVoidFailure(failure: QrVoidFailure) {
                val message = when (failure) {
                    is QrVoidFailure.GeneralFailure -> failure.message
                } ?: "QR void failed"
                val envelope = ResponseHandler.errorFromFailure(
                    "QR_VOID_FAILURE",
                    failure,
                    message
                )
                sendQrEvent(
                    requestId,
                    "onQrVoidFailure",
                    envelope["message"] as? String ?: message,
                    envelope
                )
            }

            override fun onNearpayException(nearPayException: NearpayException) {
                val envelope = ResponseHandler.errorFromFailure(
                    "QR_VOID_FAILURE",
                    nearPayException,
                    nearPayException.message ?: "QR void failed"
                )
                sendQrEvent(
                    requestId,
                    "onQrVoidFailure",
                    envelope["message"] as? String ?: "QR void failed",
                    envelope
                )
            }
        }

        try {
            if (location != null) {
                terminal.qrVoid(
                    intentId = intentId,
                    originalIntentId = originalIntentId,
                    location = location,
                    qrVoidListener = listener
                )
            } else {
                terminal.qrVoid(
                    intentId = intentId,
                    originalIntentId = originalIntentId,
                    qrVoidListener = listener
                )
            }
            response(
                ResponseHandler.success(
                    "QR void started",
                    mapOf("requestId" to requestId, "responseType" to "QrVoid")
                )
            )
        } catch (e: Exception) {
            Timber.tag("QrVoidOperation").e(e, "QR void failed")
            response(
                ResponseHandler.errorFromFailure(
                    "QR_VOID_FAILED",
                    e,
                    e.message ?: "QR void failed"
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
                provider.methodChannel.invokeMethod("qrVoidEvent", eventArgs)
            }
        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send qrVoidEvent: $eventType for requestId: $requestId with error: ${e.message}"
            )
        }
    }
}
