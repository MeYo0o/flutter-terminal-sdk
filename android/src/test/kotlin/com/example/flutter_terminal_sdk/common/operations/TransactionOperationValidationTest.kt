package com.example.flutter_terminal_sdk.common.operations

import kotlin.test.Test

/**
 * The argument contract of the routing and refund operations. Routing runs on a
 * short-lived session captured during lookup, so most of the surface here is
 * about refusing work whose session or terminal is already gone.
 */
class TransactionOperationValidationTest {
    @Test
    fun `routingLookup requires terminal uuid, amount and intent uuid`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_UUID",
            captureOnce { reply -> RoutingLookupOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "MISSING_AMOUNT",
            captureOnce { reply ->
                RoutingLookupOperation(provider).run(argsOf("uuid" to "uuid-1"), reply)
            }
        )
        assertErrorCode(
            "MISSING_INTENT_UUID",
            captureOnce { reply ->
                RoutingLookupOperation(provider).run(
                    argsOf("uuid" to "uuid-1", "amount" to 5000),
                    reply
                )
            }
        )
    }

    @Test
    fun `routingLookup reports a missing terminal once its arguments are complete`() {
        assertErrorCode(
            "TERMINAL_NOT_FOUND",
            captureOnce { reply ->
                RoutingLookupOperation(uninitializedProvider()).run(
                    argsOf(
                        "uuid" to "uuid-1",
                        "amount" to 5000,
                        "intentUUID" to "intent-1"
                    ),
                    reply
                )
            }
        )
    }

    @Test
    fun `routingExecute requires terminal uuid, acquirer terminal id and session id`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_UUID",
            captureOnce { reply -> RoutingExecuteOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "MISSING_SELECTED_TERMINAL_ID",
            captureOnce { reply ->
                RoutingExecuteOperation(provider).run(argsOf("uuid" to "uuid-1"), reply)
            }
        )
        assertErrorCode(
            "MISSING_SESSION",
            captureOnce { reply ->
                RoutingExecuteOperation(provider).run(
                    argsOf("uuid" to "uuid-1", "selectedAcquirerTerminalId" to "A1"),
                    reply
                )
            }
        )
    }

    @Test
    fun `routingExecute refuses a session the lookup never registered`() {
        assertErrorCode(
            "SESSION_NOT_FOUND",
            captureOnce { reply ->
                RoutingExecuteOperation(uninitializedProvider()).run(
                    argsOf(
                        "uuid" to "uuid-1",
                        "selectedAcquirerTerminalId" to "A1",
                        "sessionId" to "expired-session"
                    ),
                    reply
                )
            }
        )
    }

    @Test
    fun `routingInstallments needs a non-empty, parseable option list`() {
        val provider = uninitializedProvider()
        val base: Array<Pair<String, Any?>> = arrayOf(
            "uuid" to "uuid-1",
            "selectedAcquirerTerminalId" to "A1",
            "sessionId" to "session-1"
        )

        assertErrorCode(
            "MISSING_INSTALLMENT_OPTIONS",
            captureOnce { reply ->
                RoutingInstallmentsOperation(provider).run(
                    argsOf(*base, "installmentOptions" to emptyList<Any>()),
                    reply
                )
            }
        )
        // A malformed entry is rejected the same way rather than crashing the
        // channel call.
        assertErrorCode(
            "MISSING_INSTALLMENT_OPTIONS",
            captureOnce { reply ->
                RoutingInstallmentsOperation(provider).run(
                    argsOf(*base, "installmentOptions" to listOf(mapOf("installmentCount" to "three"))),
                    reply
                )
            }
        )
        assertErrorCode(
            "SESSION_NOT_FOUND",
            captureOnce { reply ->
                RoutingInstallmentsOperation(provider).run(
                    argsOf(
                        *base,
                        "installmentOptions" to listOf(
                            mapOf(
                                "installmentCount" to 3,
                                "installmentPercentage" to 0.0,
                                "paymentPlan" to "MONTHLY",
                                "totalCalculatedAmount" to 5000.0
                            )
                        )
                    ),
                    reply
                )
            }
        )
    }

    @Test
    fun `refundWithoutTap requires terminal, transaction and refund uuids`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_UUID",
            captureOnce { reply -> RefundWithoutTapOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "MISSING_TRANSACTION_UUID",
            captureOnce { reply ->
                RefundWithoutTapOperation(provider).run(argsOf("terminalUUID" to "uuid-1"), reply)
            }
        )
        assertErrorCode(
            "MISSING_REFUND_UUID",
            captureOnce { reply ->
                RefundWithoutTapOperation(provider).run(
                    argsOf("terminalUUID" to "uuid-1", "intentUUID" to "intent-1"),
                    reply
                )
            }
        )
    }
}
