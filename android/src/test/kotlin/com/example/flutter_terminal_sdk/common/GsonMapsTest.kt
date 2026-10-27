package com.example.flutter_terminal_sdk.common

import com.google.gson.Gson
import com.google.gson.JsonNull
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

class GsonMapsTest {
    private val gson = Gson()

    @Test
    fun `toJsonMap of null returns null`() {
        assertNull(gson.toJsonMap(null))
    }

    @Test
    fun `toJsonMap of an object returns a map`() {
        val map = gson.toJsonMap(Sample(id = "abc", count = 2))

        assertNotNull(map)
        assertEquals("abc", map["id"])
        assertEquals(2, (map["count"] as Number).toInt())
    }

    @Test
    fun `toJsonMap of JsonNull returns null`() {
        assertNull(gson.toJsonMap(JsonNull.INSTANCE))
    }

    @Test
    fun `serialize failure message is stable for event senders`() {
        assertEquals("Failed to serialize response", JSON_MAP_FAILED_MESSAGE)
    }

    private data class Sample(val id: String, val count: Int)
}
