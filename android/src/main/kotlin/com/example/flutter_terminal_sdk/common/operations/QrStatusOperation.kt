package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.QrStatusResponse
import io.nearpay.terminalsdk.listeners.QrStatusListener
import io.nearpay.terminalsdk.listeners.failures.QrStatusFailure
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber

class QrStatusOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val transactionId = filter.getString("transactionId")
            ?: filter.getString("id")
            ?: filter.getString("transactionUUID")
            ?: filter.getString("transactionUuid")
            ?: return response(
                ResponseHandler.error("MISSING_TRANSACTION_ID", "transactionId is required")
            )

        val intentId = filter.getString("intentId") ?: transactionId

        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        try {
            terminal.qrStatus(
                intentId,
                object : QrStatusListener {
                    override fun onQrStatusSuccess(response2: QrStatusResponse) {
                        val map = gson.toJsonMap(response2)
                        if (map == null) {
                            response(
                                ResponseHandler.error(
                                    "SERIALIZE_FAILED",
                                    "Failed to serialize QR status"
                                )
                            )
                        } else {
                            response(ResponseHandler.success("QR status fetched", map))
                        }
                    }

                    override fun onNearpayException(nearPayException: NearpayException) {
                        response(
                            ResponseHandler.errorFromFailure(
                                "QR_STATUS_FAILURE",
                                nearPayException,
                                "Failed to fetch QR status"
                            )
                        )
                    }

                    override fun onQrStatusFailure(failure: QrStatusFailure) {}
                }
            )
        } catch (e: Exception) {
            Timber.tag("QrStatusOperation").e(e, "Failed to fetch QR status")
            response(
                ResponseHandler.errorFromFailure(
                    "QR_STATUS_FAILED",
                    e,
                    e.message ?: "Failed to fetch QR status"
                )
            )
        }
    }
}
