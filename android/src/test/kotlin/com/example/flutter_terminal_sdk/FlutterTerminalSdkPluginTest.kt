package com.example.flutter_terminal_sdk

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.mockk
import io.mockk.verify
import kotlin.test.Test

/**
 * The plugin's dispatch contract, before any operation is reached. A call that
 * arrives while the plugin has no operator factory - no `initialize`, or the
 * activity detached - must come back as a channel error, because Dart awaits
 * every call and a silent drop hangs the app.
 */
internal class FlutterTerminalSdkPluginTest {
    @Test
    fun `an operation call before initialize fails with PLUGIN_NOT_INITIALIZED`() {
        val plugin = FlutterTerminalSdkPlugin()
        val result = mockk<MethodChannel.Result>(relaxed = true)

        plugin.onMethodCall(MethodCall("purchase", null), result)

        verify(exactly = 1) { result.error("PLUGIN_NOT_INITIALIZED", any(), null) }
        verify(exactly = 0) { result.success(any()) }
    }

    @Test
    fun `getVersion answers before initialize, from the bundled fallback`() {
        val plugin = FlutterTerminalSdkPlugin()
        val result = mockk<MethodChannel.Result>(relaxed = true)

        // The example app reads the SDK version on its first frame, so this one
        // has to answer without an activity or an initialized SDK.
        plugin.onMethodCall(MethodCall("getVersion", null), result)

        verify(exactly = 1) { result.success(any<String>()) }
        verify(exactly = 0) { result.error(any(), any(), any()) }
    }
}
