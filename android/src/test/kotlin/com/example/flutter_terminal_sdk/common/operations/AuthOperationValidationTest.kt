package com.example.flutter_terminal_sdk.common.operations

import kotlin.test.Test

/**
 * The argument contract of the login operations. These are the codes Dart maps
 * to `NearpayError`, so renaming one silently breaks error handling in both
 * example apps - and on-device the same check costs a full session.
 */
class AuthOperationValidationTest {
    @Test
    fun `verifyJWT requires a jwt`() {
        assertErrorCode(
            "MISSING_JWT",
            captureOnce { reply -> VerifyJWTOperation(uninitializedProvider()).run(argsOf(), reply) }
        )
    }

    @Test
    fun `sendMobileOtp requires a mobile number, then an initialized SDK`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_MOBILE",
            captureOnce { reply -> SendMobileOtpOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "NOT_INITIALIZED",
            captureOnce { reply ->
                SendMobileOtpOperation(provider).run(argsOf("mobileNumber" to "+966500000000"), reply)
            }
        )
    }

    @Test
    fun `sendEmailOtp requires an email, then an initialized SDK`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_EMAIL",
            captureOnce { reply -> SendEmailOtpOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "NOT_INITIALIZED",
            captureOnce { reply ->
                SendEmailOtpOperation(provider).run(argsOf("email" to "e2e@example.com"), reply)
            }
        )
    }

    @Test
    fun `verifyMobileOtp requires a mobile number and a code`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_MOBILE",
            captureOnce { reply ->
                VerifyMobileOtpOperation(provider).run(argsOf("code" to "1234"), reply)
            }
        )
        assertErrorCode(
            "MISSING_CODE",
            captureOnce { reply ->
                VerifyMobileOtpOperation(provider).run(argsOf("mobileNumber" to "+966500000000"), reply)
            }
        )
    }

    @Test
    fun `verifyEmailOtp requires an email and a code`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_EMAIL",
            captureOnce { reply ->
                VerifyEmailOtpOperation(provider).run(argsOf("code" to "1234"), reply)
            }
        )
        assertErrorCode(
            "MISSING_CODE",
            captureOnce { reply ->
                VerifyEmailOtpOperation(provider).run(argsOf("email" to "e2e@example.com"), reply)
            }
        )
    }

    @Test
    fun `connectTerminal requires tid, terminal uuid and user uuid`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_TID",
            captureOnce { reply -> ConnectTerminalOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "MISSING_USER_UUID",
            captureOnce { reply ->
                ConnectTerminalOperation(provider).run(
                    argsOf("tid" to "T1", "terminalUUID" to "uuid-1"),
                    reply
                )
            }
        )
    }

    @Test
    fun `getUsers reports no users when the SDK is not initialized`() {
        assertErrorCode(
            "INVALID_USERS",
            captureOnce { reply -> GetUsersOperation(uninitializedProvider()).run(argsOf(), reply) }
        )
    }

    @Test
    fun `isTerminalReady requires a terminal uuid and a resolvable terminal`() {
        val provider = uninitializedProvider()
        assertErrorCode(
            "MISSING_terminalUUID",
            captureOnce { reply -> IsTerminalReadyOperation(provider).run(argsOf(), reply) }
        )
        assertErrorCode(
            "INVALID_TERMINAL",
            captureOnce { reply ->
                IsTerminalReadyOperation(provider).run(argsOf("terminalUUID" to "uuid-1"), reply)
            }
        )
    }
}
