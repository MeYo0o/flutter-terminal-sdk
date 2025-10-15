package com.example.flutter_terminal_sdk.common.operations

import android.app.Activity
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.TerminalConnection
import io.nearpay.terminalsdk.listeners.ConnectTerminalListener
import io.nearpay.terminalsdk.listeners.GetTerminalByIdListener
import io.nearpay.terminalsdk.listeners.failures.ConnectTerminalFailure
import io.nearpay.terminalsdk.listeners.failures.GetTerminalByIdFailure
import timber.log.Timber

class ConnectTerminalOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val tid = filter.getString("tid")
            ?: return response(ResponseHandler.error("MISSING_TID", "Terminal TID is required"))

        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_TID", "Terminal TID is required"))

        val userUUID = filter.getString("userUUID")
            ?: return response(ResponseHandler.error("MISSING_USER_UUID", "User UUID is required"))
        val user =
            try {


                provider.terminalSdk?.getUserByUUID(userUUID)
                    ?: return response(
                        ResponseHandler.error("INVALID_USER", "No user found for UUID: $userUUID")
                    )

            } catch (e: Throwable) {
                Timber.tag("ConnectTerminalOperation").e("Error getting user by UUID: $userUUID - ${e.message}")
                return response(
                    ResponseHandler.error(
                        "GET_USER_BY_UUID_FAILURE",
                        e.message ?: "Unknown error"
                    )
                )
            }
        val activity: Activity = provider.activity
            ?: return response(ResponseHandler.error("NO_ACTIVITY", "Activity reference is null"))



        Timber.tag("ConnectTerminalOperation")
            .d("Fetching terminal with terminalUUID: $terminalUUID")


        user.getTerminalById(terminalUUID, object : GetTerminalByIdListener {
            override fun onGetTerminalSuccess(terminalConnection: TerminalConnection) {
                Timber.tag("ConnectTerminalOperation")
                    .d("Connecting to terminal with TID: $tid")
                terminalConnection.connect(activity, object : ConnectTerminalListener {
                    override fun onConnectTerminalSuccess(terminal: Terminal) {
                        Timber.tag("ConnectTerminalOperation")
                            .d("Connected to terminal with TID: $tid")

                        Timber.tag("ConnectTerminalOperation")
                            .d("Connected to terminal with TID: ${terminal.terminalUUID}")

                        val resultData = mapOf(
                            "tid" to terminal.tid,
                            "isReady" to terminal.isTerminalReady(),
                            "terminalUUID" to terminal.terminalUUID,
                            "uuid" to terminalUUID,
                            "name" to terminal.name,


                            )
                        response(
                            ResponseHandler.success(
                                "Connected to terminal",
                                resultData
                            )
                        )
                    }

                    override fun onConnectTerminalFailure(connectTerminalFailure: ConnectTerminalFailure) {
                        Timber.tag("ConnectTerminalOperation").e(
                            "Failed to connect to terminal"
                        )
                        response(
                            ResponseHandler.error(
                                "CONNECT_FAILURE",
                                connectTerminalFailure.toString()
                            )
                        )
                    }
                })

            }

            override fun onGetTerminalFailure(getTerminalByIdFailure: GetTerminalByIdFailure) {
                response(
                    ResponseHandler.error(
                        "GET_TERMINAL_BY_ID_FAILURE",
                        getTerminalByIdFailure.toString()
                    )
                )
            }
        })

    }
}
