package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.RoutingProfile
import io.nearpay.terminalsdk.listeners.GetRoutingProfileListener
import io.nearpay.terminalsdk.listeners.failures.GetRoutingProfileFailure
import timber.log.Timber

class RoutingProfileOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal terminalUUID is required"))

        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        Timber.d("Got Terminal successfully")
        try {
            terminal.getRoutingProfile(
                object : GetRoutingProfileListener {

                    override fun onGetRoutingProfileFailure(error: GetRoutingProfileFailure) {
                        Timber.tag("RoutingProfileOperation")
                            .e("Failed to get routing profile: $error")
                        response(
                            ResponseHandler.errorFromFailure(
                                "GET_ROUTING_PROFILE_FAILED",
                                error,
                                "Failed to get routing profile"
                            )
                        )

                    }

                    override fun onGetRoutingProfileSuccess(profile: RoutingProfile) {
                        Timber.tag("RoutingProfileOperation")
                            .d("Successfully retrieved routing profile: $profile")
                        val map = gson.toJsonMap(profile)
                        if (map == null) {
                            response(
                                ResponseHandler.error(
                                    "SERIALIZE_FAILED",
                                    "Failed to serialize routing profile"
                                )
                            )
                        } else {
                            response(
                                ResponseHandler.success(
                                    "GET_ROUTING_PROFILE_SUCCESS",
                                    map
                                )
                            )
                        }
                    }
                },
            )
        } catch (e: Exception) {
            Timber.tag("RoutingProfileOperation").e(e, "GET_ROUTING_PROFILE_FAILED")
            response(ResponseHandler.errorFromFailure("GET_ROUTING_PROFILE_FAILED", e, "Failed to get routing profile"))
        }
    }

}
