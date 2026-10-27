package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import java.lang.reflect.Proxy
import java.util.concurrent.atomic.AtomicBoolean

internal object CashierReflectionInvoker {
    private val gson = Gson()

    fun invokeWithJsonParam(
        terminal: Any,
        methodName: String,
        paramsJson: String,
        failureCode: String,
        response: (Map<String, Any>) -> Unit
    ) {
        val method = findMethodByArity(terminal, methodName, 1)
            ?: return response(
                ResponseHandler.error(
                    "METHOD_NOT_AVAILABLE",
                    "$methodName is not available in this Terminal SDK version"
                )
            )

        val paramType = method.parameterTypes.first()
        val paramValue = try {
            gson.fromJson(paramsJson, paramType)
        } catch (e: Exception) {
            return response(
                ResponseHandler.error(
                    "INVALID_PARAMS",
                    "Invalid $methodName params: ${e.message}"
                )
            )
        }

        invokeResolved(terminal, method, listOf(paramValue), failureCode, response)
    }

    fun invokeWithStringParam(
        terminal: Any,
        methodName: String,
        value: String,
        failureCode: String,
        response: (Map<String, Any>) -> Unit
    ) {
        val method = findMethod(terminal, methodName) { params ->
            params.size == 1 && params[0] == String::class.java
        }
            ?: return response(
                ResponseHandler.error(
                    "METHOD_NOT_AVAILABLE",
                    "$methodName is not available in this Terminal SDK version"
                )
            )

        invokeResolved(terminal, method, listOf(value), failureCode, response)
    }

    fun invokeWithPagination(
        terminal: Any,
        methodName: String,
        page: Int,
        limit: Int,
        failureCode: String,
        response: (Map<String, Any>) -> Unit
    ) {
        val method = findMethod(terminal, methodName) { params ->
            params.size == 2 && isIntLike(params[0]) && isIntLike(params[1])
        }
            ?: return response(
                ResponseHandler.error(
                    "METHOD_NOT_AVAILABLE",
                    "$methodName is not available in this Terminal SDK version"
                )
            )

        invokeResolved(terminal, method, listOf(page, limit), failureCode, response)
    }

    private fun invokeResolved(
        terminal: Any,
        method: Method,
        args: List<Any?>,
        failureCode: String,
        response: (Map<String, Any>) -> Unit
    ) {
        val listenerType = method.parameterTypes.lastOrNull()
            ?: return response(
                ResponseHandler.error(
                    "METHOD_NOT_AVAILABLE",
                    "Listener for ${method.name} is missing"
                )
            )

        val settled = AtomicBoolean(false)
        val listener = Proxy.newProxyInstance(
            listenerType.classLoader,
            arrayOf(listenerType)
        ) { _, callbackMethod, callbackArgs ->
            val callbackName = callbackMethod.name.lowercase()

            if (callbackName.contains("success") || callbackName.contains("completed")) {
                if (settled.compareAndSet(false, true)) {
                    val payload = callbackArgs?.firstOrNull()
                    response(
                        ResponseHandler.success(
                            "${method.name} completed",
                            toBridgePayload(payload)
                        )
                    )
                }
            } else if (callbackName.contains("failure") || callbackName.contains("error")) {
                if (settled.compareAndSet(false, true)) {
                    val failure = callbackArgs?.firstOrNull()
                    response(
                        ResponseHandler.errorFromFailure(
                            failureCode,
                            failure,
                            "${method.name} failed"
                        )
                    )
                }
            }

            null
        }

        try {
            val invocationArgs = args.toMutableList().apply { add(listener) }
            method.invoke(terminal, *invocationArgs.toTypedArray())
        } catch (e: InvocationTargetException) {
            val cause = e.targetException ?: e
            response(
                ResponseHandler.errorFromFailure(
                    failureCode,
                    cause,
                    cause.message ?: "${method.name} invocation failed"
                )
            )
        } catch (e: Exception) {
            response(
                ResponseHandler.errorFromFailure(
                    failureCode,
                    e,
                    e.message ?: "${method.name} invocation failed"
                )
            )
        }
    }

    private fun findMethodByArity(terminal: Any, methodName: String, arity: Int): Method? =
        findMethod(terminal, methodName) { params -> params.size == arity }

    private fun findMethod(
        terminal: Any,
        methodName: String,
        paramsPredicate: (Array<Class<*>>) -> Boolean
    ): Method? {
        return terminal.javaClass.methods.firstOrNull { method ->
            if (method.name != methodName) return@firstOrNull false
            val parameterTypes = method.parameterTypes
            if (parameterTypes.isEmpty()) return@firstOrNull false
            val listenerType = parameterTypes.last()
            if (!listenerType.isInterface) return@firstOrNull false

            val argsOnly: Array<Class<*>> = Array(parameterTypes.size - 1) { index ->
                parameterTypes[index]
            }
            paramsPredicate(argsOnly)
        }
    }

    private fun isIntLike(type: Class<*>): Boolean {
        return type == Int::class.javaPrimitiveType || type == Int::class.javaObjectType
    }

    private fun toBridgePayload(value: Any?): Any {
        if (value == null || value == Unit) {
            return emptyMap<String, Any>()
        }
        return when (value) {
            is String, is Number, is Boolean -> value
            is Map<*, *> -> normalize(value)
            is List<*> -> normalize(value)
            else -> {
                val json = gson.toJson(value)
                val type = object : TypeToken<Any>() {}.type
                normalize(gson.fromJson(json, type))
            }
        }
    }

    private fun normalize(value: Any?): Any {
        return when (value) {
            null -> emptyMap<String, Any>()
            is Map<*, *> -> value.entries
                .filter { it.key is String }
                .associate { it.key as String to normalize(it.value) }
            is List<*> -> value.map { normalize(it) }
            is String, is Number, is Boolean -> value
            else -> value.toString()
        }
    }
}
