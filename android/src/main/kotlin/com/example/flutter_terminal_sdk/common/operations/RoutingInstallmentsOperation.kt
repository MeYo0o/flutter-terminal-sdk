package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.InstallmentOption
import io.nearpay.terminalsdk.data.dto.PurchaseResponse
import io.nearpay.terminalsdk.listeners.SendTransactionListener
import io.nearpay.terminalsdk.listeners.failures.SendTransactionFailure
import timber.log.Timber

class RoutingInstallmentsOperation(provider: NearpayProvider) : BaseOperation(provider) {
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

        val installmentOptions = parseInstallmentOptions(filter.getList("installmentOptions"))
            ?: return response(
                ResponseHandler.error(
                    "MISSING_INSTALLMENT_OPTIONS",
                    "A non-empty list of installment options is required"
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
            Timber.tag("RoutingInstallmentsOperation")
                .d("Executing routing installments with sessionId: $sessionId, selectedAcquirerTerminalId: $selectedAcquirerTerminalId, options: ${installmentOptions.size}, customerReferenceNumber: $customerReferenceNumber")

            terminal.routingInstallments(
                session = session,
                selectedAcquirerTerminalId = selectedAcquirerTerminalId,
                installmentOptions = installmentOptions,
                customerReferenceNumber = customerReferenceNumber,
                sendTransactionListener = object : SendTransactionListener {
                    override fun onSendTransactionFailure(sendTransactionFailure: SendTransactionFailure) {
                        Timber.tag("RoutingInstallmentsOperation")
                            .d("Routing installments failed $sendTransactionFailure")
                        provider.clearRoutingSession(sessionId)
                        response(
                            ResponseHandler.errorFromFailure(
                                "ROUTING_INSTALLMENTS_FAILURE",
                                sendTransactionFailure,
                                "Routing installments failed"
                            )
                        )
                    }

                    override fun onSendTransactionCompleted(transactionResponse: PurchaseResponse) {
                        provider.clearRoutingSession(sessionId)
                        Timber.tag("RoutingInstallmentsOperation")
                            .d("Routing installments completed $transactionResponse")
                        val map = gson.toJsonMap(transactionResponse)
                        if (map == null) {
                            response(
                                ResponseHandler.error(
                                    "SERIALIZE_FAILED",
                                    "Failed to serialize routing installments response"
                                )
                            )
                        } else {
                            response(ResponseHandler.success("ROUTING_INSTALLMENTS_SUCCESS", map))
                        }
                    }
                }
            )
        } catch (e: Exception) {
            Timber.tag("RoutingInstallmentsOperation").e(e, "ROUTING_INSTALLMENTS_FAILED")
            provider.clearRoutingSession(sessionId)
            response(
                ResponseHandler.errorFromFailure(
                    "ROUTING_INSTALLMENTS_FAILED",
                    e,
                    "Routing installments failed"
                )
            )
        }
    }

    private fun parseInstallmentOptions(raw: List<*>?): List<InstallmentOption>? {
        if (raw.isNullOrEmpty()) return null
        return try {
            raw.map { item ->
                val map = item as Map<*, *>
                InstallmentOption(
                    installmentCount = (map["installmentCount"] as Number).toInt(),
                    installmentPercentage = (map["installmentPercentage"] as Number).toDouble(),
                    paymentPlan = map["paymentPlan"] as String,
                    totalCalculatedAmount = (map["totalCalculatedAmount"] as Number).toDouble()
                )
            }
        } catch (e: Exception) {
            Timber.tag("RoutingInstallmentsOperation")
                .e(e, "Failed to parse installment options")
            null
        }
    }
}
