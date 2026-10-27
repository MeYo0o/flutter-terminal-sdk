package com.example.flutter_terminal_sdk.common.filter

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Every operation reads its arguments through this class, so its coercion rules
 * decide whether a Dart call arrives intact. Dart sends ints for whole numbers
 * and doubles for fractions, which is why the numeric getters go through
 * [Number] rather than casting to the exact type.
 */
class ArgsFilterTest {
    private val filter = ArgsFilter(
        mapOf(
            "text" to "hello",
            "int" to 42,
            "long" to 9_000_000_000L,
            "double" to 12.5,
            "flag" to true,
            "list" to listOf("a", "b"),
            "wrongType" to listOf<String>()
        )
    )

    @Test
    fun `reads each supported type`() {
        assertEquals("hello", filter.getString("text"))
        assertEquals(42, filter.getInt("int"))
        assertEquals(9_000_000_000L, filter.getLong("long"))
        assertEquals(12.5, filter.getDouble("double"))
        assertEquals(true, filter.getBoolean("flag"))
        assertEquals(listOf("a", "b"), filter.getList("list"))
    }

    @Test
    fun `numbers cross the int and long boundary in both directions`() {
        // Dart sends any whole number as an int, so an amount in minor units
        // arrives as an Int and still has to read back as a Long.
        assertEquals(42L, filter.getLong("int"))
        assertEquals(-1, ArgsFilter(mapOf("long" to 4_294_967_295L)).getInt("long"))
    }

    @Test
    fun `missing keys and wrong types read as null rather than throwing`() {
        assertNull(filter.getString("absent"))
        assertNull(filter.getString("int"))
        assertNull(filter.getInt("text"))
        assertNull(filter.getBoolean("text"))
        assertNull(filter.getList("text"))
        assertNull(filter.getDouble("wrongType"))
    }

    @Test
    fun `a call with no arguments reads as all null`() {
        val empty = ArgsFilter(null)
        assertNull(empty.getString("text"))
        assertNull(empty.getLong("long"))
        assertNull(empty.getList("list"))
    }

    @Test
    fun `a whole double reads as a long`() {
        assertEquals(12L, ArgsFilter(mapOf("taxPercentage" to 12.0)).getLong("taxPercentage"))
        assertEquals(12, ArgsFilter(mapOf("taxPercentage" to 12.0)).getInt("taxPercentage"))
    }

    @Test
    fun `a fractional number reads as null rather than truncating`() {
        val fractional = ArgsFilter(mapOf("taxPercentage" to 12.5))

        assertNull(fractional.getLong("taxPercentage"))
        assertNull(fractional.getInt("taxPercentage"))
    }

    @Test
    fun `hasKey separates an absent key from an unreadable value`() {
        val fractional = ArgsFilter(mapOf("taxPercentage" to 12.5))

        assertTrue(fractional.hasKey("taxPercentage"))
        assertFalse(fractional.hasKey("surchargeAmount"))
        assertFalse(ArgsFilter(null).hasKey("taxPercentage"))
    }

    @Test
    fun `an int-valued double does not read as a double`() {
        // getDouble casts rather than coercing, so `amount: 10` from Dart is not
        // a Double. Operations that accept fractions must send one.
        assertNull(ArgsFilter(mapOf("amount" to 10)).getDouble("amount"))
        assertEquals(10.0, ArgsFilter(mapOf("amount" to 10.0)).getDouble("amount"))
    }
}
