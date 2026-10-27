package com.example.flutter_terminal_sdk.common.filter

class ArgsFilter(private val args: Map<*, *>?) {
    fun hasKey(key: String): Boolean = args?.containsKey(key) == true

    fun getString(key: String): String? = args?.get(key) as? String

    fun getStringAnyOf(vararg keys: String): String? {
        for (key in keys) {
            val value = getString(key)?.trim()?.takeIf { it.isNotEmpty() }
            if (value != null) return value
        }
        return null
    }

    private fun getWholeNumber(key: String): Number? {
        val number = args?.get(key) as? Number ?: return null
        val numericValue = number.toDouble()
        if (!numericValue.isFinite() || numericValue % 1.0 != 0.0) return null
        return number
    }

    fun getLong(key: String): Long? = getWholeNumber(key)?.toLong()
    fun getInt(key: String): Int? = getWholeNumber(key)?.toInt()

    fun getBoolean(key: String): Boolean? = args?.get(key) as? Boolean
    fun getDouble(key: String): Double? = args?.get(key) as? Double
    fun getList(key: String): List<*>? = args?.get(key) as? List<*>
}
