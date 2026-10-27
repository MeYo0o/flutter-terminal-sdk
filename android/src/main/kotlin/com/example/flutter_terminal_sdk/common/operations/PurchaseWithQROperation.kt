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
import io.nearpay.terminalsdk.data.dto.GeneratedQRCode
import io.nearpay.terminalsdk.data.dto.IntentDetails
import io.nearpay.terminalsdk.data.dto.Location
import io.nearpay.terminalsdk.data.dto.PurchaseResponse
import io.nearpay.terminalsdk.data.dto.QrStatusResponse
import io.nearpay.terminalsdk.listeners.QrPaymentUiListener
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber

class PurchaseWithQROperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val id = filter.getString("id")
            ?: return response(ResponseHandler.error("MISSING_id", "Terminal id is required"))

        val amount = filter.getString("amount")
            ?: return response(ResponseHandler.error("MISSING_AMOUNT", "Amount is required"))

        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        val enableUiDismiss = filter.getBoolean("enableUiDismiss") ?: true

        val lat = filter.getDouble("lat")
        val long = filter.getDouble("long")
        val isLocationFromMock = filter.getBoolean("isLocationFromMock")
        val location = if (lat != null && long != null) {
            Location(long = long, lat = lat, isLocationFromMock = isLocationFromMock)
        } else {
            null
        }

        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        Timber.d("Got Terminal successfully")
        try {
            val qrPaymentUiListener = object : QrPaymentUiListener {

                    override fun onQrUiPresented(qrCode: GeneratedQRCode) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrUiPresented : $qrCode")
                        sendSerializedQrEvent(id, "qrUiPresented", qrCode)
                    }

                    override fun onQrPaymentStatusUpdated(status: QrStatusResponse) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusUpdated: $status")
                        sendSerializedQrEvent(id, "qrPaymentStatusUpdated", status)
                    }

                    override fun onQrPaymentStatusExpired(status: QrStatusResponse) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusExpired: $status")
                        sendSerializedQrEvent(id, "qrPaymentStatusExpired", status)
                    }

                    override fun onQrPaymentStatusCompleted(status: QrStatusResponse) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusCompleted: $status")
                        sendSerializedQrEvent(id, "qrPaymentStatusCompleted", status)
                    }

                    override fun onQrPaymentApproved(response: PurchaseResponse) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentApproved: ${response.details}")
                        sendSerializedQrEvent(id, "qrPaymentApproved", response.details)
                    }

                    override fun onQrPaymentDeclined(response: PurchaseResponse?) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentDeclined: ${response?.details}")
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentDeclined",
                            null,
                            gson.toJsonMap(response?.details)
                        )
                    }

                    override fun onQrPaymentFailure(message: String) {
                        Timber.tag("PurchaseWithQrOperation").d("onQrPaymentFailure: $message")
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentFailure",
                            message,
                            null
                        )
                    }

                    override fun onQrPaymentStatusFailed(status: QrStatusResponse) {
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusFailed: $status")
                        sendSerializedQrEvent(id, "qrPaymentStatusFailed", status)
                    }

                    override fun onUiClosed() {
                        Timber.tag("PurchaseWithQrOperation").d("onUiClosed")
                        sendPurchaseWithQREvent(
                            id,
                            "uiClosed",
                            null,
                            null
                        )

                    }

                    override fun onNearpayException(nearPayException: NearpayException) {
                        val message = nearPayException.message ?: "QR payment failed"
                        Timber.tag("PurchaseWithQrOperation")
                            .e("onNearpayException: $message")
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentFailure",
                            message,
                            null
                        )
                    }

                }

            if (location != null) {
                terminal.generateQrCodeWithUi(
                    intentId = id,
                    amount = amount,
                    location = location,
                    customerReferenceNumber = customerReferenceNumber,
                    enableUiDismiss = enableUiDismiss,
                    qrPaymentUiListener = qrPaymentUiListener
                )
            } else {
                terminal.generateQrCodeWithUi(
                    intentId = id,
                    amount = amount,
                    customerReferenceNumber = customerReferenceNumber,
                    enableUiDismiss = enableUiDismiss,
                    qrPaymentUiListener = qrPaymentUiListener
                )
            }
            response(ResponseHandler.success("Purchase with QR operation started"))
        } catch (e: Exception) {
            Timber.tag("PurchaseWithQrOperation").e(e, "Purchase operation failed")
            response(
                ResponseHandler.errorFromFailure(
                    "PURCHASE_FAILED",
                    e,
                    "Purchase with qr failed"
                )
            )
        }
    }

    private fun sendSerializedQrEvent(id: String, eventType: String, value: Any) {
        val map = gson.toJsonMap(value)
        if (map == null) {
            sendPurchaseWithQREvent(id, "qrPaymentFailure", JSON_MAP_FAILED_MESSAGE, null)
        } else {
            sendPurchaseWithQREvent(id, eventType, null, map)
        }
    }

    private fun sendPurchaseWithQREvent(
        id: String,
        eventType: String,
        message: String?,
        data: Any?
    ) {
        val eventArgs = mutableMapOf<String, Any>(
            "intentUUID" to id,
            "type" to eventType
        )
        message?.let { eventArgs["message"] = it }
        data?.let { eventArgs["data"] = it }

        try {
            Handler(Looper.getMainLooper()).post {
                provider.methodChannel.invokeMethod("purchaseWithQREvent", eventArgs)
            }

        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send purchase with qr event: $eventType for id: $id with error: ${e.message}"
            )
            throw e;
        }
    }
}
