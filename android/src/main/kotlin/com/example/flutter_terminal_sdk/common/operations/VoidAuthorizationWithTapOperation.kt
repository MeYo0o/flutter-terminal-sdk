package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.JSON_MAP_FAILED_MESSAGE
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.VoidAuthorizationResponse
import io.nearpay.terminalsdk.listeners.ReadCardListener
import io.nearpay.terminalsdk.listeners.VoidListener
import io.nearpay.terminalsdk.listeners.failures.ReadCardFailure
import io.nearpay.terminalsdk.listeners.failures.VoidFailure
import timber.log.Timber

class VoidAuthorizationWithTapOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val amount = filter.getLong("amount")
            ?: return response(ResponseHandler.error("MISSING_AMOUNT", "Amount is required"))

        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "UUID is required"))

        val authorizationUuid = filter.getString("authorizationUuid")
            ?: filter.getString("authorizationUUID")
            ?: return response(
                ResponseHandler.error(
                    "MISSING_AUTHORIZATION_UUID",
                    "Authorization UUID is required"
                )
            )

        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        try {
            terminal.voidAuthorizationWithTap(
                amount,
                uuid,
                authorizationUuid,
                object : VoidListener {
                    override fun onVoidCompleted(voidResponse: VoidAuthorizationResponse) {
                        Timber.tag("VoidAuthorizationWithTapOperation").d("onVoidCompleted")
                        val map = gson.toJsonMap(voidResponse)
                        if (map == null) {
                            sendVoidAuthorizationWithTapEvent(
                                authorizationUuid,
                                "sendTransactionFailure",
                                JSON_MAP_FAILED_MESSAGE,
                                null
                            )
                        } else {
                            sendVoidAuthorizationWithTapEvent(
                                authorizationUuid,
                                "voidWithTapCompleted",
                                null,
                                map
                            )
                        }
                    }

                    override fun onVoidFailure(voidFailure: VoidFailure) {
                        Timber.tag("VoidAuthorizationWithTapOperation")
                            .d("onVoidFailure $voidFailure")
                        sendVoidAuthorizationWithTapEvent(
                            authorizationUuid,
                            "sendTransactionFailure",
                            ResponseHandler.eventMessage(voidFailure),
                            null
                        )
                    }
                },
                customerReferenceNumber,
                object : ReadCardListener {
                    override fun onReaderClosed() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerClosed", null, null)
                    }

                    override fun onReaderDismissed() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerDismissed", null, null)
                    }

                    override fun onReaderDisplayed() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerDisplayed", null, null)
                    }

                    override fun onReadCardSuccess() {
                        sendVoidAuthorizationWithTapEvent(
                            authorizationUuid,
                            "cardReadSuccess",
                            "Card read successfully",
                            null
                        )
                    }

                    override fun onReadCardFailure(readCardFailure: ReadCardFailure) {
                        sendVoidAuthorizationWithTapEvent(
                            authorizationUuid,
                            "cardReadFailure",
                            ResponseHandler.eventMessage(readCardFailure),
                            null
                        )
                    }

                    override fun onReaderWaiting() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerWaiting", null, null)
                    }

                    override fun onReaderReading() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerReading", null, null)
                    }

                    override fun onReaderRetry() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerRetry", null, null)
                    }

                    override fun onPinEntering() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "pinEntering", null, null)
                    }

                    override fun onReaderFinished() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readerFinished", null, null)
                    }

                    override fun onReaderError(error: String?) {
                        sendVoidAuthorizationWithTapEvent(
                            authorizationUuid,
                            "readerError",
                            error ?: "Unknown reader error",
                            null
                        )
                    }

                    override fun onReadingStarted() {
                        sendVoidAuthorizationWithTapEvent(authorizationUuid, "readingStarted", null, null)
                    }
                }
            )
            response(ResponseHandler.success("Void authorization with tap started"))
        } catch (e: Exception) {
            Timber.tag("VoidAuthorizationWithTapOperation")
                .e(e, "Void authorization with tap failed")
            response(
                ResponseHandler.errorFromFailure(
                    "VOID_AUTHORIZATION_WITH_TAP_FAILED",
                    e,
                    "Void authorization with tap failed"
                )
            )
        }
    }

    private fun sendVoidAuthorizationWithTapEvent(
        authorizationUuid: String,
        eventType: String,
        message: String?,
        data: Any?
    ) {
        val eventArgs = mutableMapOf<String, Any>(
            "uuid" to authorizationUuid,
            "authorizationUuid" to authorizationUuid,
            "type" to eventType
        )
        message?.let { eventArgs["message"] = it }
        data?.let { eventArgs["data"] = it }

        try {
            Handler(Looper.getMainLooper()).post {
                provider.methodChannel.invokeMethod("voidAuthorizationWithTapEvent", eventArgs)
            }
        } catch (e: Exception) {
            Timber.e(
                e,
                "Failed to send voidAuthorizationWithTap event: $eventType for $authorizationUuid: ${e.message}"
            )
            throw e
        }
    }
}
