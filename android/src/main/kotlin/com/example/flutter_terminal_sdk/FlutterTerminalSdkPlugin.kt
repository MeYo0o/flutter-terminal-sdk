package com.example.flutter_terminal_sdk

import NearpayOperatorFactory
import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.example.flutter_terminal_sdk.common.NearpayProvider
import timber.log.Timber
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class FlutterTerminalSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var provider: NearpayProvider? = null
    private var operatorFactory: NearpayOperatorFactory? = null
    private val pluginScope = CoroutineScope(Dispatchers.IO)

    private val backgroundMethods = setOf("routingLookup", "routingExecute", "routingInstallments", "getRoutingProfile")

    companion object {
        private const val TERMINAL_SDK_VERSION_FALLBACK = "0.0.181-SNAPSHOT5-LITE"
        private const val TERMINAL_SDK_INFO_CLASS = "io.nearpay.terminalsdk.utils.GetSdkInfoKt"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        attachToMessenger(flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext, null)
    }

    private fun attachToMessenger(
        binaryMessenger: BinaryMessenger,
        applicationContext: Context,
        attachedActivity: Activity?
    ) {
        Timber.uprootAll()

        context = applicationContext
        channel = MethodChannel(binaryMessenger, "nearpay_plugin")
        channel.setMethodCallHandler(this)

        attachedActivity?.let { attachActivity(it) }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachActivity(binding.activity)
    }

    private fun attachActivity(attachedActivity: Activity) {
        activity = attachedActivity
        val attachedProvider = provider ?: NearpayProvider(attachedActivity, channel).also {
            provider = it
        }
        attachedProvider.attachActivity(attachedActivity)
        operatorFactory = NearpayOperatorFactory(attachedProvider)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        provider = null
        operatorFactory = null
    }

    override fun onDetachedFromActivity() {
        activity = null
        provider?.detachActivity()
        operatorFactory = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val argsFilter = ArgsFilter(call.arguments())

        when (call.method) {
            "initialize" -> {
                pluginScope.launch {
                    try {
                        val attachedProvider = provider
                            ?: throw IllegalStateException("Activity must be attached before initializing Nearpay plugin")

                        if (!attachedProvider.isInitialized()) {
                            attachedProvider.initializeSdk(argsFilter)
                        }

                        if (operatorFactory == null) {
                            operatorFactory = NearpayOperatorFactory(attachedProvider)
                        }
                        Timber.d("Did initialize")
                        withContext(Dispatchers.Main) {
                            result.success("Initialization successful")
                        }
                    } catch (e: Throwable) {
                        withContext(Dispatchers.Main) {
                            result.error(
                                "INITIALIZATION_FAILED",
                                "Failed to initialize Nearpay plugin: ${e.message}",
                                e
                            )
                        }
                    }
                }
            }

            "getVersion" -> {
                val nativeVersion = activity?.let { resolveNativeTerminalSdkVersion(it) }
                result.success(nativeVersion ?: TERMINAL_SDK_VERSION_FALLBACK)
            }

            else -> {
                if (operatorFactory == null) {
                    result.error(
                        "PLUGIN_NOT_INITIALIZED",
                        "Nearpay plugin not initialized properly. Ensure you have called the initialize method first.",
                        null
                    )
                    return
                }

                val operation = operatorFactory!!.getOperation(call.method)

                if (operation != null) {
                    if (call.method in backgroundMethods) {
                        pluginScope.launch {
                            try {
                                operation.run(argsFilter) { response ->
                                    pluginScope.launch(Dispatchers.Main) {
                                        deliver(call.method, response, result)
                                    }
                                }
                            } catch (e: Throwable) {
                                withContext(Dispatchers.Main) {
                                    result.success(operationFailedResponse(e))
                                }
                            }
                        }
                    } else {
                        try {
                            operation.run(argsFilter) { response ->
                                deliver(call.method, response, result)
                            }
                        } catch (e: Throwable) {
                            result.success(operationFailedResponse(e))
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    private fun deliver(
        method: String,
        response: Map<String, Any>,
        result: MethodChannel.Result
    ) {
        if (method == "disconnectTerminal") {
            emitDisconnectEventIfNeeded(response)
        }
        result.success(response)
    }

    private fun operationFailedResponse(error: Throwable): Map<String, Any> =
        ResponseHandler.errorFromFailure(
            "OPERATION_FAILED",
            error,
            error.message ?: "Operation failed"
        )

    private fun emitDisconnectEventIfNeeded(response: Map<*, *>) {
        val status = (response["status"] as? String)?.trim()?.lowercase()
        if (status != "success") return
        val data = response["data"] as? Map<*, *> ?: return
        val disconnected = data["disconnected"] as? Boolean ?: return
        if (!disconnected) return
        val terminalUUID = (data["terminalUUID"] as? String)?.trim()?.takeIf { it.isNotEmpty() }
            ?: return
        pluginScope.launch(Dispatchers.Main) {
            channel.invokeMethod(
                "NearpayTerminalOnDisconnect",
                mapOf("terminalUUID" to terminalUUID)
            )
        }
    }

    private fun resolveNativeTerminalSdkVersion(activity: Activity): String? {
        return runCatching {
            val sdkInfoClass = Class.forName(TERMINAL_SDK_INFO_CLASS)
            val getSdkVersionMethod = sdkInfoClass.getMethod("getSdkVersion", Activity::class.java)
            (getSdkVersionMethod.invoke(null, activity) as? String)
                ?.trim()
                ?.takeIf { it.isNotEmpty() }
        }.getOrNull()
    }
}
