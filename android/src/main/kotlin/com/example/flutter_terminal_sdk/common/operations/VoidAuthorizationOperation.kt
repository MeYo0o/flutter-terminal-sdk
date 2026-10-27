package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.data.dto.VoidAuthorizationResponse
import timber.log.Timber

class VoidAuthorizationOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_ID", "uuid is required"))

        val amount = filter.getLong("amount")

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        terminal.voidAuthorization(
            uuid = uuid,
            voidListener = object : io.nearpay.terminalsdk.listeners.VoidListener {

                override fun onVoidCompleted(voidResponse: VoidAuthorizationResponse) {
                    Timber.tag("AuthorizeVoidOperation").d("onVoidCompleted")
                    val map = gson.toJsonMap(voidResponse)
                    if (map == null) {
                        response(
                            ResponseHandler.error(
                                "SERIALIZE_FAILED",
                                "Failed to serialize void authorization"
                            )
                        )
                    } else {
                        response(
                            ResponseHandler.success(
                                "Void completed successfully",
                                map
                            )
                        )
                    }
                }

                override fun onVoidFailure(voidFailure: io.nearpay.terminalsdk.listeners.failures.VoidFailure) {
                    Timber.tag("AuthorizeVoidOperation").d("onVoidFailure $voidFailure")
                    response(
                        ResponseHandler.errorFromFailure(
                            "VOID_AUTHORIZATION_FAILURE",
                            voidFailure,
                            "Void authorization failed"
                        )
                    )
                }
            },
            amount = amount,
        )

    }

}