package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.listeners.CancelTransactionListener
import io.nearpay.terminalsdk.listeners.failures.CancelTransactionFailure
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.Unit
import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

class CancelTransactionOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val id = (filter.getString("id")
            ?: filter.getString("transactionUUID")
            ?: filter.getString("transactionUuid"))?.trim()

        if (id.isNullOrEmpty()) {
            return response(ResponseHandler.error("MISSING_ID", "Transaction ID is required"))
        }

        val terminalUUID = filter.getString("terminalUUID")
            ?: provider.connectedTerminalUUID
            ?: return response(ResponseHandler.error("NO_TERMINAL", "No connected terminal"))

        val activity = provider.activity
            ?: return response(ResponseHandler.error("NO_ACTIVITY", "Activity reference is null"))

        val terminal = provider.terminalSdk?.getTerminal(activity, terminalUUID)
            ?: return response(
                ResponseHandler.error("INVALID_TERMINAL", "No terminal found for UUID: $terminalUUID")
            )

        val settled = AtomicBoolean(false)

        try {
            val provideUseCaseMethod = terminal.javaClass.getDeclaredMethod("provideCancelTransactionUseCase")
            provideUseCaseMethod.isAccessible = true
            val cancelUseCase = provideUseCaseMethod.invoke(terminal)
                ?: return response(
                    ResponseHandler.error("CANCEL_FAILED", "Cancel transaction use case is unavailable")
                )

            val invokeMethod = cancelUseCase.javaClass.getDeclaredMethod(
                "invoke",
                String::class.java,
                String::class.java,
                CancelTransactionListener::class.java,
                Continuation::class.java
            )
            invokeMethod.isAccessible = true
            invokeMethod.invoke(
                cancelUseCase,
                null,
                id,
                object : CancelTransactionListener {
                    override fun onCancelTransactionSuccess(responseData: io.nearpay.terminalsdk.data.dto.PurchaseResponse) {
                        if (!settled.compareAndSet(false, true)) return
                        response(
                            ResponseHandler.success(
                                "Transaction cancelled",
                                mapOf("canceled" to true)
                            )
                        )
                    }

                    override fun onNearpayException(nearPayException: NearpayException) {
                        if (!settled.compareAndSet(false, true)) return
                        response(
                            ResponseHandler.errorFromFailure(
                                "CANCEL_FAILED",
                                nearPayException,
                                "Cancel transaction failed"
                            )
                        )
                    }

                    override fun onCancelTransactionFailure(unused: CancelTransactionFailure) {}
                },
                object : Continuation<Unit> {
                    override val context: CoroutineContext
                        get() = EmptyCoroutineContext

                    override fun resumeWith(result: Result<Unit>) {
                        result.exceptionOrNull()?.let { error ->
                            if (!settled.compareAndSet(false, true)) return
                            response(
                                ResponseHandler.errorFromFailure(
                                    "CANCEL_FAILED",
                                    error,
                                    "Cancel transaction failed"
                                )
                            )
                        }
                    }
                }
            )
        } catch (e: Exception) {
            Timber.tag("CancelTransactionOperation").e("Cancel transaction failed: ${e.message}")
            response(
                ResponseHandler.errorFromFailure(
                    "CANCEL_FAILED",
                    e,
                    "Cancel transaction failed"
                )
            )
        }
    }
}
