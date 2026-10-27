package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.JSON_MAP_FAILED_MESSAGE
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.RoutingSession
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.Location
import io.nearpay.terminalsdk.data.dto.PaymentScheme
import io.nearpay.terminalsdk.data.dto.RoutingResponse
import io.nearpay.terminalsdk.listeners.ReadCardListener
import io.nearpay.terminalsdk.listeners.RoutingLookupListener
import io.nearpay.terminalsdk.listeners.failures.ReadCardFailure
import timber.log.Timber

class RoutingLookupOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val amount = filter.getLong("amount")
            ?: return response(ResponseHandler.error("MISSING_AMOUNT", "Amount is required"))

        val intentUUID = filter.getString("intentUUID")
            ?: return response(
                ResponseHandler.error(
                    "MISSING_INTENT_UUID",
                    "intent UUID is required"
                )
            )
        val schemeString = filter.getString("scheme")
        val scheme = schemeString?.uppercase()?.let { PaymentScheme.valueOf(it) }

        val lat = filter.getDouble("lat")
        val long = filter.getDouble("long")
        val isLocationFromMock = filter.getBoolean("isLocationFromMock")
        val location =
            if (lat != null && long != null) {
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

        val readCardListener = object : ReadCardListener {
            override fun onReaderClosed() {
                Timber.tag("RoutingLookupOperation").d("onReaderClosed")
                sendPurchaseEvent(intentUUID, "readerClosed", null, null)
            }

            override fun onReaderDismissed() {
                Timber.tag("RoutingLookupOperation").d("onReaderDismissed")
                sendPurchaseEvent(intentUUID, "readerDismissed", null, null)
            }

            override fun onReaderDisplayed() {
                Timber.tag("RoutingLookupOperation").d("onReaderDisplayed")
                sendPurchaseEvent(intentUUID, "readerDisplayed", null, null)
            }

            override fun onReadCardSuccess() {
                Timber.tag("RoutingLookupOperation").d("onReadCardSuccess")
                sendPurchaseEvent(
                    intentUUID,
                    "cardReadSuccess",
                    "Card read successfully",
                    null
                )
            }

            override fun onReadCardFailure(readCardFailure: ReadCardFailure) {
                Timber.tag("RoutingLookupOperation").d("onReadCardFailure $readCardFailure")
                sendPurchaseEvent(
                    intentUUID,
                    "cardReadFailure",
                    ResponseHandler.eventMessage(readCardFailure),
                    null
                )
            }

            override fun onReaderWaiting() {
                Timber.tag("RoutingLookupOperation").d("onReaderWaiting")
                sendPurchaseEvent(intentUUID, "readerWaiting", null, null)
            }

            override fun onReaderReading() {
                Timber.tag("RoutingLookupOperation").d("onReaderReading")
                sendPurchaseEvent(intentUUID, "readerReading", null, null)
            }

            override fun onReaderRetry() {
                Timber.tag("RoutingLookupOperation").d("onReaderRetry")
                sendPurchaseEvent(intentUUID, "readerRetry", null, null)
            }

            override fun onPinEntering() {
                Timber.tag("RoutingLookupOperation").d("onPinEntering")
                sendPurchaseEvent(intentUUID, "pinEntering", null, null)
            }

            override fun onReaderFinished() {
                Timber.tag("RoutingLookupOperation").d("onReaderFinished")
                sendPurchaseEvent(intentUUID, "readerFinished", null, null)
            }

            override fun onReaderError(error: String?) {
                Timber.tag("RoutingLookupOperation").d("onReaderError $error")
                sendPurchaseEvent(
                    intentUUID,
                    "readerError",
                    error ?: "Unknown reader error",
                    null
                )
            }

            override fun onReadingStarted() {
                Timber.tag("RoutingLookupOperation").d("onReadingStarted")
                sendPurchaseEvent(intentUUID, "readingStarted", null, null)
            }
        }

        val lookupListener = object : RoutingLookupListener {

            override fun onRoutingLookupCompleted(
                response: RoutingResponse,
                session: RoutingSession
            ) {
                Timber.tag("RoutingLookupOperation")
                    .d("onRoutingLookupCompleted $response")
                Timber.tag("RoutingLookupOperation")
                    .d("onRoutingLookupCompleted session: $session")

                val responseMap = gson.toJsonMap(response)
                if (responseMap == null) {
                    sendPurchaseEvent(
                        intentUUID,
                        "routingLookupFailure",
                        JSON_MAP_FAILED_MESSAGE,
                        null
                    )
                    return
                }

                provider.saveRoutingSession(intentUUID, session)
                provider.saveRoutingTerminal(intentUUID, terminal)

                sendPurchaseEvent(
                    intentUUID,
                    "routingLookupCompleted",
                    null,
                    mapOf(
                        "response" to responseMap,
                        "sessionId" to intentUUID
                    )
                )
            }

            override fun onRoutingLookupFailure(routingLookupFailure: io.nearpay.terminalsdk.listeners.failures.RoutingLookupFailure) {
                Timber.tag("RoutingLookupOperation")
                    .d("onRoutingLookupFailure $routingLookupFailure")
                sendPurchaseEvent(
                    intentUUID,
                    "routingLookupFailure",
                    ResponseHandler.eventMessage(routingLookupFailure),
                    null
                )
            }
        }

        try {
            if (location != null) {
                terminal.routingLookup(
                    amount = amount,
                    scheme = scheme,
                    intentUUID = intentUUID,
                    location = location,
                    readCardListener = readCardListener,
                    routingLookupListener = lookupListener,
                )
            } else {
                terminal.routingLookup(
                    amount = amount,
                    scheme = scheme,
                    intentUUID = intentUUID,
                    readCardListener = readCardListener,
                    routingLookupListener = lookupListener,
                )
            }
            response(ResponseHandler.success("Routing lookup started"))
        } catch (e: Exception) {
            Timber.tag("RoutingLookupOperation")
                .e(e, "Exception during routing lookup: ${e.message}")
            response(ResponseHandler.errorFromFailure("PURCHASE_FAILED", e, "Routing lookup failed"))
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
                provider.methodChannel.invokeMethod("RoutingLookupEvent", eventArgs)
            }

        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send RoutingLookup event: $eventType for intentUUID: $intentUUID with error: ${e.message}"
            )
            throw e;
        }
    }
}
