package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import android.util.Base64
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.RoutingSession
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.PurchaseResponse
import io.nearpay.terminalsdk.listeners.SendTransactionListener
import io.nearpay.terminalsdk.listeners.failures.SendTransactionFailure
import timber.log.Timber
import com.google.gson.*
import java.lang.reflect.Type
import java.time.Instant

class InstantAdapter : JsonSerializer<Instant>, JsonDeserializer<Instant> {
    override fun serialize(
        src: Instant?,
        typeOfSrc: Type?,
        context: JsonSerializationContext?
    ): JsonElement {
        return JsonPrimitive(src?.toString())
    }

    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): Instant {
        return Instant.parse(json?.asString)
    }
}

class RoutingExecuteOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val selectedAcquirerTerminalId = filter.getString("selectedAcquirerTerminalId")
            ?: return response(
                ResponseHandler.error(
                    "MISSING_SELECTED_TERMINAL_ID",
                    "Selected Acquirer Terminal ID is required"
                )
            )

        val customerReferenceNumber = filter.getString("customerReferenceNumber")

        val sessionId = filter.getString("sessionId")
            ?: return response(
                ResponseHandler.error(
                    "MISSING_SESSION",
                    "Session Id is required"
                )
            )

        val session = provider.getRoutingSession(sessionId) ?: return response(
            ResponseHandler.error(
                "SESSION_NOT_FOUND",
                "No session found for sessionId = $sessionId"
            )
        )

        val terminal: Terminal = provider.getRoutingTerminal(sessionId)
            ?: provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        Timber.d("Got Terminal successfully")
        try {

            Timber.tag("RoutingExecuteOperation")
                .d("Executing routing with sessionId: $sessionId, selectedAcquirerTerminalId: $selectedAcquirerTerminalId, customerReferenceNumber: $customerReferenceNumber")

            Timber.tag("RoutingExecuteOperation").d("Session details: $session")

            terminal.routingExecute(
                session = session,
                selectedAcquirerTerminalId =
                    selectedAcquirerTerminalId,
                customerReferenceNumber = customerReferenceNumber,
                sendTransactionListener = object : SendTransactionListener {
                    override fun onSendTransactionFailure(sendTransactionFailure: SendTransactionFailure) {
                        Timber.tag("RoutingExecuteOperation")
                            .d("Routing execute failed $sendTransactionFailure")
                        provider.clearRoutingSession(sessionId)
                        response(
                            ResponseHandler.errorFromFailure(
                                "ROUTING_EXECUTE_FAILURE",
                                sendTransactionFailure,
                                "Routing execute failed"
                            )
                        )
                    }

                    override fun onSendTransactionCompleted(transactionResponse: PurchaseResponse) {
                        provider.clearRoutingSession(sessionId)
                        Timber.tag("RoutingExecuteOperation")
                            .d("Routing execute completed $transactionResponse")
                        val map = gson.toJsonMap(transactionResponse)
                        if (map == null) {
                            response(
                                ResponseHandler.error(
                                    "SERIALIZE_FAILED",
                                    "Failed to serialize routing execute response"
                                )
                            )
                        } else {
                            response(ResponseHandler.success("ROUTING_EXECUTE_SUCCESS", map))
                        }
                    }
                }
            )
        } catch (e: Exception) {
            Timber.tag("RoutingExecuteOperation").e(e, "ROUTING_EXECUTE_FAILED")
            provider.clearRoutingSession(sessionId)
            response(
                ResponseHandler.errorFromFailure(
                    "ROUTING_EXECUTE_FAILED",
                    e,
                    "Routing execute failed"
                )
            )
        }
    }

}
