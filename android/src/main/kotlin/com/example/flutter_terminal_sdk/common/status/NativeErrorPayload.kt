package com.example.flutter_terminal_sdk.common.status

import io.nearpay.softpos.utils.NearPayError
import io.nearpay.terminalsdk.data.dto.LocalizationField
import io.nearpay.terminalsdk.data.dto.MessageError
import io.nearpay.terminalsdk.utils.NearpayException as TerminalSdkNearpayException
import org.json.JSONArray
import org.json.JSONObject
import java.lang.reflect.Method
import java.lang.reflect.Modifier
import java.util.Locale

internal object NativeErrorPayload {
    fun fromBridge(
        code: String,
        message: String,
        nativeType: String? = null,
        details: Map<String, Any?>? = null
    ): Map<String, Any> {
        val payload = linkedMapOf<String, Any?>(
            "type" to (nativeType?.takeIf { it.isNotBlank() } ?: code),
            "message" to message
        )

        mergeDetail(
            base = null,
            extra = details?.let { serializeValue(it) }
        )?.let { payload["detail"] = it }

        return normalizePayload(payload)
    }

    fun fromFailure(
        code: String,
        failure: Any?,
        message: String? = null,
        details: Map<String, Any?>? = null
    ): Map<String, Any> {
        val resolvedMessage = resolveMessage(code, failure, message)
        val payload = linkedMapOf<String, Any?>(
            "type" to resolveType(code, failure),
            "message" to resolvedMessage
        )
        extractLocalizedMessage(failure)?.let { payload["localizedMessage"] = it }

        mergeDetail(
            base = extractFailureDetail(failure, resolvedMessage),
            extra = details?.let { serializeValue(it) }
        )?.let { payload["detail"] = it }

        return normalizePayload(payload)
    }

    fun localizedMessageString(failure: Any?): String? {
        if (failure !is TerminalSdkNearpayException) {
            return null
        }
        val me = failure.messageError ?: return null
        return localizedEnglishOrArabic(me.error) ?: localizedEnglishOrArabic(me.solution)
    }

    private fun resolveType(code: String, failure: Any?): String =
        nativeType(failure) ?: code

    private fun nativeType(failure: Any?): String? {
        val exception = failure as? TerminalSdkNearpayException ?: return null
        return messageErrorCodeText(exception.messageError) ?: "NearpayException"
    }

    private fun resolveMessage(
        code: String,
        failure: Any?,
        message: String?
    ): String {
        val explicitMessage = message?.trim().orEmpty()
        if (explicitMessage.isNotEmpty()) {
            return explicitMessage
        }

        if (failure != null) {
            if (failure is TerminalSdkNearpayException) {
                localizedEnglishOrArabic(failure.messageError?.error)?.let { return it }
                localizedEnglishOrArabic(failure.messageError?.solution)?.let { return it }
            }
            extractStringGetter(failure, "message")
                ?.takeIf { it.isNotBlank() }
                ?.let { return it }
        }

        return failure?.toString() ?: "$code failed"
    }

    private fun extractFailureDetail(failure: Any?, resolvedMessage: String): Any? {
        if (failure == null) {
            return null
        }

        return when (failure) {
            is NearPayError.ServerError -> failure.errorResponse?.toJson()?.let { serializeValue(it) }
            is NearPayError.NetworkError -> linkedMapOf(
                "details" to failure.details
            )

            is TerminalSdkNearpayException -> terminalSdkNearpayDetail(failure, resolvedMessage)

            else -> {
                val serialized = serializeValue(failure)
                when {
                    serialized == null -> null
                    serialized == resolvedMessage -> null
                    serialized is Map<*, *> && serialized.isEmpty() -> null
                    else -> serialized
                }
            }
        }
    }

    private fun mergeDetail(base: Any?, extra: Any?): Any? {
        if (base == null) {
            return extra
        }
        if (extra == null) {
            return base
        }

        if (base is Map<*, *> && extra is Map<*, *>) {
            val merged = linkedMapOf<String, Any?>()
            base.forEach { (key, value) ->
                key?.toString()?.let { merged[it] = value }
            }
            extra.forEach { (key, value) ->
                key?.toString()?.let { merged[it] = value }
            }
            return merged.takeIf { it.isNotEmpty() }
        }

        return linkedMapOf(
            "value" to base,
            "extra" to extra
        )
    }

    private fun normalizePayload(payload: Map<String, Any?>): Map<String, Any> {
        return payload
            .filterValues { it != null }
            .mapValues { it.value as Any }
    }

    private fun serializeValue(
        value: Any?,
        visited: MutableSet<Int> = mutableSetOf()
    ): Any? {
        return when (value) {
            null -> null
            is String, is Number, is Boolean -> value
            is Enum<*> -> value.name
            is JSONObject -> jsonObjectToMap(value, visited)
            is JSONArray -> jsonArrayToList(value, visited)
            is Map<*, *> -> value.entries
                .mapNotNull { (key, nestedValue) ->
                    val serialized = serializeValue(nestedValue, visited) ?: return@mapNotNull null
                    key?.toString()?.let { it to serialized }
                }
                .toMap(linkedMapOf())
                .takeIf { it.isNotEmpty() }
            is Iterable<*> -> value.mapNotNull { serializeValue(it, visited) }
            is Array<*> -> value.mapNotNull { serializeValue(it, visited) }
            else -> serializeObject(value, visited)
        }
    }

    private fun serializeObject(
        value: Any,
        visited: MutableSet<Int>
    ): Any? {
        val identity = System.identityHashCode(value)
        if (!visited.add(identity)) {
            return null
        }

        try {
            invokeNoArgMethod(value, "toJson")
                ?.let { return serializeValue(it, visited) }

            val payload = linkedMapOf<String, Any?>()
            publicGetterMethods(value.javaClass)
                .forEach { method ->
                    val property = propertyName(method) ?: return@forEach
                    if (property in IGNORED_PROPERTIES) {
                        return@forEach
                    }

                    val nestedValue = runCatching { method.invoke(value) }.getOrNull()
                    if (property == "message" && nestedValue is String) {
                        return@forEach
                    }

                    val serialized = serializeValue(nestedValue, visited) ?: return@forEach
                    payload[property] = serialized
                }

            return payload.takeIf { it.isNotEmpty() }
        } finally {
            visited.remove(identity)
        }
    }

    private fun publicGetterMethods(type: Class<*>): List<Method> {
        return type.methods
            .filter { method ->
                Modifier.isPublic(method.modifiers) &&
                    method.parameterCount == 0 &&
                    method.name != "getClass" &&
                    (method.name.startsWith("get") || method.name.startsWith("is"))
            }
            .sortedBy { it.name }
    }

    private fun propertyName(method: Method): String? {
        return when {
            method.name.startsWith("get") && method.name.length > 3 ->
                method.name.substring(3).replaceFirstChar { it.lowercase() }

            method.name.startsWith("is") && method.name.length > 2 ->
                method.name.substring(2).replaceFirstChar { it.lowercase() }

            else -> null
        }
    }

    private fun invokeNoArgMethod(value: Any, name: String): Any? {
        val method = runCatching {
            value.javaClass.methods.firstOrNull {
                it.name == name &&
                    Modifier.isPublic(it.modifiers) &&
                    it.parameterCount == 0
            }
        }.getOrNull() ?: return null

        return runCatching { method.invoke(value) }.getOrNull()
    }

    private fun extractStringGetter(value: Any, property: String): String? {
        val getter = buildString {
            append("get")
            append(property.replaceFirstChar { it.uppercase() })
        }

        return runCatching {
            value.javaClass.methods.firstOrNull {
                it.name == getter &&
                    Modifier.isPublic(it.modifiers) &&
                    it.parameterCount == 0
            }?.invoke(value) as? String
        }.getOrNull()
    }

    private fun jsonObjectToMap(
        value: JSONObject,
        visited: MutableSet<Int>
    ): Map<String, Any?>? {
        val payload = linkedMapOf<String, Any?>()
        val iterator = value.keys()
        while (iterator.hasNext()) {
            val key = iterator.next()
            val nestedValue = value.opt(key)
            val serialized = serializeValue(
                if (nestedValue == JSONObject.NULL) null else nestedValue,
                visited
            ) ?: continue
            payload[key] = serialized
        }
        return payload.takeIf { it.isNotEmpty() }
    }

    private fun jsonArrayToList(
        value: JSONArray,
        visited: MutableSet<Int>
    ): List<Any?> {
        return buildList {
            for (index in 0 until value.length()) {
                val item = value.opt(index)
                add(
                    serializeValue(
                        if (item == JSONObject.NULL) null else item,
                        visited
                    )
                )
            }
        }
    }

    private val IGNORED_PROPERTIES = setOf(
        "companion",
        "creator",
        "default",
        "serializer"
    )

    private fun terminalSdkNearpayDetail(
        failure: TerminalSdkNearpayException,
        resolvedMessage: String
    ): Any? {
        val payload = linkedMapOf<String, Any?>()
        extractStringGetter(failure, "technicalMessage")
            ?.takeIf { it.isNotBlank() && it != resolvedMessage }
            ?.let { payload["technicalMessage"] = it }
        failure.messageError?.let { me ->
            payload["messageError"] = messageErrorToMap(me)
        }
        return payload.takeIf { it.isNotEmpty() }
    }

    private fun messageErrorToMap(me: MessageError): Map<String, Any?> {
        return linkedMapOf<String, Any?>(
            "type" to me.code,
            "code_text" to messageErrorCodeText(me),
            "statusCode" to me.statusCode,
            "terminalPausedSeconds" to me.terminalPausedSeconds,
            "level" to me.level?.toString(),
            "source" to me.source?.english,
            "error" to localizationFieldToMap(me.error),
            "solution" to localizationFieldToMap(me.solution)
        ).filterValues { value ->
            when (value) {
                null -> false
                is String -> value.isNotBlank()
                is Map<*, *> -> value.isNotEmpty()
                else -> true
            }
        }
    }

    private fun messageErrorCodeText(me: MessageError?): String? =
        me?.code_text?.takeIf { it.isNotBlank() }

    private fun extractLocalizedMessage(failure: Any?): Map<String, String>? {
        val terminalFailure = failure as? TerminalSdkNearpayException ?: return null
        val me = terminalFailure.messageError ?: return null

        val localized = localizationFieldToMap(me.error)
            ?: localizationFieldToMap(me.solution)

        return localized
    }

    private fun localizationFieldToMap(field: LocalizationField?): Map<String, String>? {
        if (field == null) {
            return null
        }
        val out = linkedMapOf<String, String>()
        field.english?.takeIf { it.isNotBlank() }?.let { out["english"] = it }
        field.arabic?.takeIf { it.isNotBlank() }?.let { out["arabic"] = it }
        return out.takeIf { it.isNotEmpty() }
    }

    private fun devicePrefersArabic(): Boolean {
        val lang = Locale.getDefault().language.lowercase(Locale.ROOT)
        return lang.startsWith("ar")
    }

    private fun localizedEnglishOrArabic(field: LocalizationField?): String? {
        if (field == null) {
            return null
        }
        val en = field.english?.takeIf { it.isNotBlank() }
        val ar = field.arabic?.takeIf { it.isNotBlank() }
        return if (devicePrefersArabic()) {
            ar ?: en
        } else {
            en ?: ar
        }
    }
}
