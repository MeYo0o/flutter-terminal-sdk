package com.example.flutter_terminal_sdk

import NearpayOperatorFactory
import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
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
    private lateinit var provider: NearpayProvider
    private var operatorFactory: NearpayOperatorFactory? = null
    private val pluginScope = CoroutineScope(Dispatchers.IO)


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Timber.uprootAll() // Remove any existing Timber logs
//         Optionally, comment out or remove this line to disable Timber completely:
//        Timber.plant(Timber.DebugTree());

        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nearpay_plugin")
        channel.setMethodCallHandler(this)
        provider = NearpayProvider(context!!, channel)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        provider.attachActivity(activity!!)
        operatorFactory = NearpayOperatorFactory(provider)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        activity = null
        provider.detachActivity()
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
                        if (!provider.isInitialized()) {
                            provider.initializeSdk(argsFilter)
                        }

                        if (operatorFactory == null) {
                            operatorFactory = NearpayOperatorFactory(provider)
                        }
                        Timber.d("Did initialize")
                        withContext(Dispatchers.Main) {
                            result.success("Initialization successful")
                        }
                    } catch (e: Exception) {
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
                    operation.run(argsFilter) { response ->
                        result.success(response)
                    }
                } else {
                    result.notImplemented()
                }
            }
        }
    }
}
