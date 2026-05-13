package com.example.flutter_terminal_sdk.common

import android.app.Activity
import android.content.Context
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import io.flutter.plugin.common.MethodChannel
import io.nearpay.softpos.reader_ui.UiDockPosition
import io.nearpay.softpos.reader_ui.utils.SupportSecondDisplay
import io.nearpay.terminalsdk.NetworkConfiguration
import io.nearpay.terminalsdk.SdkEnvironment
import io.nearpay.terminalsdk.TerminalSDK
import io.nearpay.terminalsdk.data.dto.Country
import io.nearpay.terminalsdk.data.dto.PermissionStatus
import io.nearpay.terminalsdk.listeners.TerminalSDKInitializationListener
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import timber.log.Timber

class NearpayProvider(private val appContext: Activity, val methodChannel: MethodChannel) {
    var activity: Activity? = null
    private var isSdkInitialized = false
    var terminalSdk: TerminalSDK? = null

    suspend fun initializeSdk(filter: ArgsFilter) {
        if (isSdkInitialized) return

        if (activity == null) {
            throw IllegalStateException("Activity must be attached before initializing NearpayProvider")
        }

        // Extract parameters from ArgsFilter (with some default values if needed)
        val environment = filter.getString("environment") ?: throw IllegalArgumentException("Environment is required")
        val country = filter.getString("country") ?: throw IllegalArgumentException("Country is required")
        val googleCloudProjectNumber = filter.getLong("googleCloudProjectNumber") ?: throw IllegalArgumentException("Google Cloud Project Number is required")
        val huaweiSafetyDetectApiKey: String? = filter.getString("huaweiSafetyDetectApiKey")
        val uiDockPositionString: String? = filter.getString("uiDockPosition")
        val secondDisplayDockPosition: String? = filter.getString("secondDisplayDockPosition")
        val pinPosition: String? = filter.getString("pinPosition")
        val supportSecondDisplay: String? = filter.getString("supportSecondDisplay")
        val networkConfigurationString: String? = filter.getString("networkConfiguration")
        val networkConfigurationId: Int? = filter.getInt("networkConfigurationId")

        Timber.d("Initializing TerminalSDK with uiDockPositionString: $uiDockPositionString")
        Timber.d("Initializing TerminalSDK with secondDisplayDockPosition: $secondDisplayDockPosition")
        Timber.d("Initializing TerminalSDK with UiDockPosition: ${UiDockPosition.toString()}")
        Timber.d("Initializing TerminalSDK with country: $country")
        Timber.d("Initializing TerminalSDK with supportSecondDisplay: $supportSecondDisplay")
        Timber.d("Initializing TerminalSDK with pinPosition: $pinPosition")
        Timber.d("Initializing TerminalSDK with networkConfiguration: $networkConfigurationString id=$networkConfigurationId")

        // Convert environment string to SdkEnvironment enum
        val sdkEnvironment = when (environment.uppercase()) {
            "PRODUCTION" -> SdkEnvironment.PRODUCTION
            "SANDBOX" -> SdkEnvironment.SANDBOX
            "INTERNAL" -> SdkEnvironment.INTERNAL
            else -> SdkEnvironment.SANDBOX // Fallback
        }

        // Convert country string to Country enum
        val sdkCountry = when (country.uppercase()) {
            "SA" -> Country.SA
            "TR" -> Country.TR
            "USA" -> Country.USA
            "JO" -> Country.JO
            "UAE" -> Country.UAE
            else -> Country.SA // Fallback
        }


        val uiDockPositionValue = when (uiDockPositionString?.uppercase()) {
            "TOP_LEFT" -> UiDockPosition.TOP_LEFT
            "TOP_RIGHT" -> UiDockPosition.TOP_RIGHT
            "BOTTOM_LEFT" -> UiDockPosition.BOTTOM_LEFT
            "BOTTOM_RIGHT" -> UiDockPosition.BOTTOM_RIGHT
            "CENTER_RIGHT" -> UiDockPosition.CENTER_RIGHT
            "CENTER_LEFT" -> UiDockPosition.CENTER_LEFT
            "ABSOLUTE_CENTER" -> UiDockPosition.ABSOLUTE_CENTER
            "TOP_CENTER" -> UiDockPosition.TOP_CENTER
            "BOTTOM_CENTER" -> UiDockPosition.BOTTOM_CENTER
            else -> null // Fallback to default if not provided
        }
        val secondDisplayDockPositionValue = when (secondDisplayDockPosition?.uppercase()) {
            "TOP_LEFT" -> UiDockPosition.TOP_LEFT
            "TOP_RIGHT" -> UiDockPosition.TOP_RIGHT
            "BOTTOM_LEFT" -> UiDockPosition.BOTTOM_LEFT
            "BOTTOM_RIGHT" -> UiDockPosition.BOTTOM_RIGHT
            "CENTER_RIGHT" -> UiDockPosition.CENTER_RIGHT
            "CENTER_LEFT" -> UiDockPosition.CENTER_LEFT
            "ABSOLUTE_CENTER" -> UiDockPosition.ABSOLUTE_CENTER
            "TOP_CENTER" -> UiDockPosition.TOP_CENTER
            "BOTTOM_CENTER" -> UiDockPosition.BOTTOM_CENTER
            else -> null // Fallback to default if not provided
        }

        val pinPositionValue = when (pinPosition?.uppercase()) {
            "TOP_LEFT" -> UiDockPosition.TOP_LEFT
            "TOP_RIGHT" -> UiDockPosition.TOP_RIGHT
            "BOTTOM_LEFT" -> UiDockPosition.BOTTOM_LEFT
            "BOTTOM_RIGHT" -> UiDockPosition.BOTTOM_RIGHT
            "CENTER_RIGHT" -> UiDockPosition.CENTER_RIGHT
            "CENTER_LEFT" -> UiDockPosition.CENTER_LEFT
            "ABSOLUTE_CENTER" -> UiDockPosition.ABSOLUTE_CENTER
            "TOP_CENTER" -> UiDockPosition.TOP_CENTER
            "BOTTOM_CENTER" -> UiDockPosition.BOTTOM_CENTER
            else -> null // Fallback to default if not provided
        }

        val supportSecondDisplayValue = when (supportSecondDisplay?.uppercase()) {
            "ENABLE" -> SupportSecondDisplay.ENABLE
            "DISABLE" -> SupportSecondDisplay.DISABLE
            "INITIAL" -> SupportSecondDisplay.DEFAULT
            else -> null // Fallback
        }

        val networkConfigurationValue: NetworkConfiguration? = when {
            networkConfigurationId != null ->
                NetworkConfiguration.fromId(networkConfigurationId)
            networkConfigurationString != null -> when (networkConfigurationString.uppercase()) {
                "NETWORKDEFAULT", "DEFAULT" -> NetworkConfiguration.DEFAULT
                "SIMPREFERRED", "SIM_PREFERRED" -> NetworkConfiguration.SIM_PREFERRED
                "SIMONLY", "SIM_ONLY" -> NetworkConfiguration.SIM_ONLY
                else -> null
            }
            else -> null
        }

        Timber.d("Initializing TerminalSDK with sdkEnvironment: $sdkEnvironment")
        Timber.d("Initializing TerminalSDK with country: $sdkCountry")
        Timber.d("Initializing TerminalSDK with supportSecondDisplay: $supportSecondDisplayValue")
        Timber.d("Initializing TerminalSDK with secondDisplayDockPosition: $secondDisplayDockPositionValue")
        Timber.d("Initializing TerminalSDK with uiDockPosition: $uiDockPositionValue")
        Timber.d("Initializing TerminalSDK with pinPositionValue: $pinPositionValue")
        Timber.d("Initializing TerminalSDK with networkConfigurationValue: $networkConfigurationValue")


        try {
            val builder = TerminalSDK.Builder()
                .activity(activity!!)
                .environment(sdkEnvironment)
                .country(sdkCountry)
                .googleCloudProjectNumber(googleCloudProjectNumber)
                .apply {
                    huaweiSafetyDetectApiKey?.let { huaweiSafetyDetectApiKey(it) }
                    uiDockPositionValue?.let { uiDockPosition(it) }
                    pinPositionValue?.let { pinPosition(it) }
                    supportSecondDisplayValue?.let { supportSecondDisplay(it) }
                    secondDisplayDockPositionValue?.let { secondDisplayDockPosition(it) }
                    networkConfigurationValue?.let { networkConfiguration(it) }
                    initializationListener(object : TerminalSDKInitializationListener {
                        override fun onInitializationFailure(throwable: Throwable) {
                            Timber.tag("TerminalSDKInit")
                                .e(throwable, "TerminalSDK initialization failed")
                            CoroutineScope(Dispatchers.IO).launch {
                                withContext(Dispatchers.Main) {
                                    methodChannel.invokeMethod(
                                        "onSdkInitializationFailed",
                                        mapOf(
                                            "error" to throwable.message
                                        )
                                    )
                                }
                            }


                        }

                        override fun onInitializationSuccess() {
                            Timber.tag("TerminalSDKInit").d("TerminalSDK initialized successfully")

                            CoroutineScope(Dispatchers.IO).launch {
                                withContext(Dispatchers.Main) {
                                    methodChannel.invokeMethod("onSdkInitialized", null)
                                }
                            }

                        }
                    })
                }

            terminalSdk = builder.build()

            isSdkInitialized = true
        } catch (e: Throwable) {
            Timber.tag("TerminalSDKInit").e(e, "Failed to initialize TerminalSDK")
            throw RuntimeException("Failed to initialize TerminalSDK: ${e.message}", e)
        }
    }

    fun isInitialized(): Boolean {
        return isSdkInitialized
    }

    fun attachActivity(currentActivity: Activity) {
        activity = currentActivity
    }

    fun detachActivity() {
        activity = null
        isSdkInitialized = false
    }

    fun retrieveTerminalSdk(): TerminalSDK {
        if (!isSdkInitialized || terminalSdk == null) {
            throw IllegalStateException("TerminalSDK is not initialized. Call initializeSdk() first.")
        }
        return terminalSdk!!
    }

    fun checkRequiredPermissions(): List<PermissionStatus> {
        return retrieveTerminalSdk().checkRequiredPermissions()
    }

    fun isNfcEnabled(): Boolean {
        if (activity == null) {
            throw IllegalStateException("Activity must be attached before initializing NearpayProvider")
        }
        return retrieveTerminalSdk().isNfcEnabled(activity!!)
    }

    fun isWifiEnabled(): Boolean {

        if (activity == null) {
            throw IllegalStateException("Activity must be attached before initializing NearpayProvider")
        }
        return retrieveTerminalSdk().isWifiEnabled(activity!!)
    }
}