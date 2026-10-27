package com.example.flutter_terminal_sdk.common.operations

import android.os.Handler
import android.os.Looper
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import java.util.concurrent.atomic.AtomicBoolean

abstract class BaseOperation(protected val provider: NearpayProvider) {
    abstract fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit)

    protected fun invalidWholeNumber(
        filter: ArgsFilter,
        key: String,
        code: String
    ): Map<String, Any>? {
        if (!filter.hasKey(key) || filter.getLong(key) != null) return null
        return ResponseHandler.error(code, "$key must be a whole number")
    }

    protected fun unsupportedParameter(
        filter: ArgsFilter,
        key: String,
        code: String,
        message: String
    ): Map<String, Any>? {
        if (!filter.hasKey(key)) return null
        return ResponseHandler.error(code, message)
    }

    protected fun createSettler(
        response: (Map<String, Any>) -> Unit
    ): (Map<String, Any>) -> Unit {
        val settled = AtomicBoolean(false)
        val mainHandler = Handler(Looper.getMainLooper())
        return settle@{ envelope ->
            if (!settled.compareAndSet(false, true)) {
                return@settle
            }
            if (Looper.myLooper() == Looper.getMainLooper()) {
                response(envelope)
            } else {
                mainHandler.post { response(envelope) }
            }
        }
    }
}
