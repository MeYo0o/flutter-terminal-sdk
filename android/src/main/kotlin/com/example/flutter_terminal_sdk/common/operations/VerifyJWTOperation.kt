package com.example.flutter_terminal_sdk.common.operations


import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.JWTLoginData
import io.nearpay.terminalsdk.listeners.JWTLoginListener
import io.nearpay.terminalsdk.listeners.failures.JWTLoginFailure
import timber.log.Timber


class VerifyJWTOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val jwt = filter.getString("jwt") ?: return response(
            ResponseHandler.error("MISSING_JWT", "jwt is required")
        )

        val loginData = JWTLoginData(
            jwt = jwt,
        )
        provider.terminalSdk?.jwtLogin(loginData, object : JWTLoginListener {

            override fun onJWTLoginSuccess(terminal: Terminal) {

                // wait for the terminal to be ready
                Timber.tag("jwtLoginSuccess").d("Terminal is ready: ${terminal.isTerminalReady()}")

                if (!terminal.isTerminalReady()) {
                    Timber.tag("jwtLoginSuccess").d("Terminal is not ready yet, waiting...")
                    // wait 3 seconds for the terminal to be ready
                    val handler = android.os.Handler(android.os.Looper.getMainLooper())
                    handler.postDelayed({
                        if (terminal.isTerminalReady()) {
                            Timber.tag("jwtLoginSuccess").d("Terminal is now ready")
                            val resultData = mapOf(
                                "tid" to terminal.tid,
                                "isReady" to terminal.isTerminalReady(),
                                "terminalUUID" to terminal.terminalUUID,
                                "uuid" to terminal.terminalUUID,
                                "name" to terminal.name,
                            )
                            response(
                                ResponseHandler.success(
                                    "Login successful: ${terminal.terminalUUID}",
                                    resultData
                                )
                            )
                        } else {
                            // wait 2 seconds more
                            Timber.tag("jwtLoginSuccess")
                                .d("Terminal is still not ready after waiting 3 seconds, waiting 2 more seconds...")

                            handler.postDelayed({
                                // return the response with terminal not ready
                                Timber.tag("jwtLoginSuccess")
                                    .d("Terminal is still not ready after waiting 5 seconds")
                                val resultData = mapOf(
                                    "tid" to terminal.tid,
                                    "isReady" to terminal.isTerminalReady(),
                                    "terminalUUID" to terminal.terminalUUID,
                                    "uuid" to terminal.terminalUUID,
                                    "name" to terminal.name,
                                )
                                response(
                                    ResponseHandler.success(
                                        "Login successful but terminal is not ready: ${terminal.terminalUUID} please check the terminal ready status manually",
                                        resultData
                                    )
                                )
                            }, 2000) // 2 seconds delay

                        }
                    }, 3000) // 3 seconds delay
                } else {
                    Timber.tag("jwtLoginSuccess").d("Terminal is already ready")
                    val resultData = mapOf(
                        "tid" to terminal.tid,
                        "isReady" to terminal.isTerminalReady(),
                        "terminalUUID" to terminal.terminalUUID,
                        "uuid" to terminal.terminalUUID,
                        "name" to terminal.name,
                    )
                    response(
                        ResponseHandler.success(
                            "Login successful: ${terminal.terminalUUID}",
                            resultData
                        )
                    )
                }


            }

            override fun onJWTLoginFailure(jwtLoginFailure: JWTLoginFailure) {
                val errorMessage = (jwtLoginFailure as JWTLoginFailure.LoginFailure).message
                Timber.tag("errorMessage").d("$errorMessage")
                response(ResponseHandler.error("VERIFY_FAILURE", errorMessage.toString()))
            }
        })
    }
}