package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import io.mockk.mockk
import kotlin.test.assertEquals
import kotlin.test.fail

/**
 * A provider that behaves like the plugin before `initialize` has run: attached
 * to an activity, but with no SDK instance. Operations must reject work in that
 * state instead of dereferencing a null SDK.
 */
internal fun uninitializedProvider(): NearpayProvider =
    NearpayProvider(mockk(relaxed = true), mockk(relaxed = true)).apply {
        activity = mockk(relaxed = true)
        terminalSdk = null
    }

internal fun argsOf(vararg pairs: Pair<String, Any?>): ArgsFilter =
    ArgsFilter(pairs.toMap())

/**
 * Runs an operation and returns the single envelope it replied with. Operations
 * answer through a callback rather than a return value, and a missing or double
 * reply is itself a bug worth failing on.
 */
internal fun captureOnce(block: ((Map<String, Any>) -> Unit) -> Unit): Map<String, Any> {
    val replies = mutableListOf<Map<String, Any>>()
    block { replies.add(it) }
    return when (replies.size) {
        1 -> replies.single()
        0 -> fail("the operation never replied")
        else -> fail("the operation replied ${replies.size} times: $replies")
    }
}

internal fun assertErrorCode(expected: String, envelope: Map<String, Any>) {
    assertEquals("error", envelope["status"], "envelope was $envelope")
    assertEquals(expected, envelope["code"], "envelope was $envelope")
}
