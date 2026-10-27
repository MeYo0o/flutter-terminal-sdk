package com.example.flutter_terminal_sdk.common.status
object ResponseHandler {
    fun success(message: String, data: Any? = null): Map<String, Any> {
        return mapOf("status" to "success", "message" to message, "data" to (data ?: mapOf<String, Any>()))
    }

    fun error(code: String, message: String): Map<String, Any> {
        return mapOf("status" to "error", "code" to code, "message" to message)
    }

    fun errorFromFailure(
        code: String,
        failure: Any?,
        fallbackMessage: String? = null
    ): Map<String, Any> = runCatching {
        val native = NativeErrorPayload.fromFailure(code, failure, null)
        val resolvedMessage = (native["message"] as? String)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: fallbackMessage?.trim()?.takeIf { it.isNotEmpty() }
            ?: code

        val nativePayload = linkedMapOf<String, Any>().apply {
            putAll(native)
            this["message"] = resolvedMessage
            if ((this["type"] as? String).isNullOrBlank()) {
                this["type"] = code
            }
        }

        mapOf<String, Any>(
            "status" to "error",
            "code" to code,
            "type" to code,
            "message" to resolvedMessage,
            "nativeError" to nativePayload
        )
    }.getOrElse {
        val derived = (failure as? Throwable)?.message?.trim()?.takeIf { it.isNotEmpty() }
            ?: fallbackMessage?.trim()?.takeIf { it.isNotEmpty() }
            ?: code
        error(code, derived)
    }

    fun eventMessage(failure: Any?): String =
        NativeErrorPayload.localizedMessageString(failure)
            ?: failure?.toString()
            ?: "Operation failed"
}
