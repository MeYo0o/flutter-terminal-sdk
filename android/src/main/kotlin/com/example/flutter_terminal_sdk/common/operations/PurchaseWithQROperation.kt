package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.GeneratedQRCode
import io.nearpay.terminalsdk.data.dto.IntentDetails
import io.nearpay.terminalsdk.data.dto.QrStatusResponse
import io.nearpay.terminalsdk.listeners.QrPaymentUiListener
import timber.log.Timber

class PurchaseWithQROperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        // Extract required arguments
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val id = filter.getString("id")
            ?: return response(ResponseHandler.error("MISSING_id", "Terminal id is required"))

        val amount = filter.getString("amount")
            ?: return response(ResponseHandler.error("MISSING_AMOUNT", "Amount is required"))

        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        val enableUiDismiss = filter.getBoolean("enableUiDismiss") ?: true


        // Retrieve the TerminalSDK instance
        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        Timber.d("Got Terminal successfully")
        try {
            // Initiate the purchase process
            terminal.generateQrCodeWithUi(
                id = id,
                amount = amount,
                customerReferenceNumber = customerReferenceNumber,
                enableUiDismiss = enableUiDismiss,
                qrPaymentUiListener = object : QrPaymentUiListener {

                    override fun onQrUiPresented(qrCode: GeneratedQRCode) {
                        val jsonString = gson.toJson(qrCode)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrUiPresented : $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrUiPresented",
                            null,
                            map

                        )
                    }

                    override fun onQrPaymentStatusUpdated(status: QrStatusResponse) {
                        val jsonString = gson.toJson(status)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusUpdated: $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentStatusUpdated",
                            null,
                            map
                        )
                    }

                    override fun onQrPaymentStatusExpired(status: QrStatusResponse) {
                        val jsonString = gson.toJson(status)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusExpired: $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentStatusExpired",
                            null,
                            map
                        )
                    }

                    override fun onQrPaymentStatusCompleted(status: QrStatusResponse) {
                        val jsonString = gson.toJson(status)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusCompleted: $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentStatusCompleted",
                            null,
                            map
                        )
                    }

                    override fun onQrPaymentApproved(intent: IntentDetails) {
                        val jsonString = gson.toJson(intent)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentApproved: $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentApproved",
                            null,
                            map
                        )
                    }

                    override fun onQrPaymentDeclined(intent: IntentDetails?) {
                        val jsonString = gson.toJson(intent)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentDeclined: $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentDeclined",
                            null,
                            map
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
                        val jsonString = gson.toJson(status)
                        Timber.tag("PurchaseWithQrOperation")
                            .d("onQrPaymentStatusFailed: $jsonString")
                        val map = gson.fromJson(jsonString, Map::class.java) as Map<*, *>
                        sendPurchaseWithQREvent(
                            id,
                            "qrPaymentStatusFailed",
                            null,
                            map
                        )
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


                }

            )
        } catch (e: Exception) {
            Timber.tag("PurchaseWithQrOperation").e(e, "Purchase operation failed")
            response(
                ResponseHandler.error(
                    "PURCHASE_FAILED",
                    "Purchase with qr failed: ${e.message}"
                )
            )
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
            // Log the error but do not disrupt the purchase flow
            Timber.e(
                e,
                "Failed to send purchase with qr event: $eventType for id: $id with error: ${e.message}"
            )
            throw e;
        }
    }
}
