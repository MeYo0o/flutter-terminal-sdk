package com.example.flutter_terminal_sdk.common.status

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Every method-channel reply is built here, and the Dart layer branches on the
 * exact keys. These are the envelopes `normalizeToNativeErrorModel` parses on
 * the other side.
 */
class ResponseHandlerTest {
    @Test
    fun `success carries an empty data map when the operation returns nothing`() {
        val envelope = ResponseHandler.success("Terminal connected")

        assertEquals("success", envelope["status"])
        assertEquals("Terminal connected", envelope["message"])
        assertEquals(emptyMap<String, Any>(), envelope["data"])
    }

    @Test
    fun `success passes payload data through untouched`() {
        val data = mapOf("tid" to "T1", "isReady" to true)
        val envelope = ResponseHandler.success("Login successful", data)

        assertEquals(data, envelope["data"])
    }

    @Test
    fun `error is a bare envelope with no native error attached`() {
        val envelope = ResponseHandler.error("MISSING_JWT", "jwt is required")

        assertEquals("error", envelope["status"])
        assertEquals("MISSING_JWT", envelope["code"])
        assertEquals("jwt is required", envelope["message"])
        // A validation failure the bridge raised itself has no SDK failure to
        // describe, so Dart falls back to NearpayNativeError.minimal.
        assertFalse(envelope.containsKey("nativeError"))
    }

    @Test
    fun `errorFromFailure prefers the failure's own message over the fallback`() {
        val envelope = ResponseHandler.errorFromFailure(
            "OTP_FAILURE",
            IllegalStateException("Terminal is paused"),
            "Failed to send OTP"
        )

        assertEquals("error", envelope["status"])
        assertEquals("OTP_FAILURE", envelope["code"])
        // `type` mirrors `code` so Dart can read either; both must be the
        // bridge's code, not the failure's class name.
        assertEquals("OTP_FAILURE", envelope["type"])
        assertEquals("Terminal is paused", envelope["message"])

        val nativeError = envelope["nativeError"]
        assertTrue(nativeError is Map<*, *>)
        nativeError as Map<*, *>
        assertEquals("OTP_FAILURE", nativeError["type"])
        assertEquals("Terminal is paused", nativeError["message"])
    }

    @Test
    fun `errorFromFailure reads a message off a non-throwable failure`() {
        // SDK failures are sealed classes, not exceptions; the payload is built
        // reflectively from their getters.
        val envelope = ResponseHandler.errorFromFailure(
            "VERIFY_FAILURE",
            FakeFailure("Invalid code"),
            "Failed to verify OTP"
        )

        assertEquals("Invalid code", envelope["message"])
        assertNotNull(envelope["nativeError"])
    }

    @Test
    fun `errorFromFailure without a failure names the code`() {
        val envelope = ResponseHandler.errorFromFailure("ROUTING_EXECUTE_FAILED", null)

        assertEquals("error", envelope["status"])
        assertEquals("ROUTING_EXECUTE_FAILED", envelope["code"])
        assertEquals("ROUTING_EXECUTE_FAILED failed", envelope["message"])
    }

    @Test
    fun `eventMessage falls back for failures with no localized content`() {
        assertEquals("Operation failed", ResponseHandler.eventMessage(null))
        assertEquals("plain failure", ResponseHandler.eventMessage(FakeFailure("plain failure")))
    }

    private class FakeFailure(private val text: String) {
        fun getMessage(): String = text
        override fun toString(): String = text
    }
}
