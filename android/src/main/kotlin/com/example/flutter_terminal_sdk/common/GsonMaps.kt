package com.example.flutter_terminal_sdk.common

import com.google.gson.Gson

internal const val JSON_MAP_FAILED_MESSAGE = "Failed to serialize response"

internal fun Gson.toJsonMap(value: Any?): Map<*, *>? {
    if (value == null) return null
    return fromJson(toJson(value), Map::class.java) as? Map<*, *>
}
