package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.ProxyRoomResponse
import io.nearpay.terminalsdk.listeners.CreateProxyRoomListener
import io.nearpay.terminalsdk.listeners.failures.CreateProxyRoomFailure
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber

class CreateProxyRoomOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("terminalUUID")
            ?: return response(
                ResponseHandler.error("MISSING_UUID", "Terminal terminalUUID is required")
            )

        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        Timber.d("Got Terminal successfully")
        try {
            terminal.createProxyRoom(
                object : CreateProxyRoomListener {
                    override fun onCreateProxyRoomSuccess(proxyRoomResponse: ProxyRoomResponse) {
                        val map = gson.toJsonMap(proxyRoomResponse)
                        if (map == null) {
                            response(
                                ResponseHandler.error(
                                    "SERIALIZE_FAILED",
                                    "Failed to serialize proxy room"
                                )
                            )
                        } else {
                            response(
                                ResponseHandler.success(
                                    "Proxy room created successfully",
                                    map
                                )
                            )
                        }
                    }

                    override fun onNearpayException(nearPayException: NearpayException) {
                        response(
                            ResponseHandler.errorFromFailure(
                                "CREATE_PROXY_ROOM_FAILURE",
                                nearPayException,
                                null
                            )
                        )
                    }

                    override fun onCreateProxyRoomFailure(unused: CreateProxyRoomFailure) {}
                }
            )
        } catch (e: Exception) {
            Timber.tag("CreateProxyRoomOperation").e(e, "CREATE_PROXY_ROOM_FAILED")
            response(
                ResponseHandler.errorFromFailure(
                    "CREATE_PROXY_ROOM_FAILED",
                    e,
                    "Create proxy room failed: ${e.message}"
                )
            )
        }
    }
}
