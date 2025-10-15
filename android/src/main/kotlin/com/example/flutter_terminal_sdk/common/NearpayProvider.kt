package com.example.flutter_terminal_sdk.common

import android.app.Activity
import android.content.Context
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import io.flutter.plugin.common.MethodChannel
import io.nearpay.terminalsdk.SdkEnvironment
import io.nearpay.terminalsdk.TerminalSDK
import io.nearpay.terminalsdk.data.dto.Country
import io.nearpay.terminalsdk.data.dto.PermissionStatus
import timber.log.Timber

class NearpayProvider(private val appContext: Context, val methodChannel: MethodChannel) {
    var activity: Activity? = null
    private var isSdkInitialized = false
    var terminalSdk: TerminalSDK? = null

    suspend fun initializeSdk(filter: ArgsFilter) {
        if (isSdkInitialized) return

        if (activity == null) {
            throw IllegalStateException("Activity must be attached before initializing NearpayProvider")
        }

        // Extract parameters from ArgsFilter (with some default values if needed)
        val environment = filter.getString("environment") ?: "sandbox"
        val googleCloudProjectNumber = filter.getLong("googleCloudProjectNumber") ?: 0
        val huaweiSafetyDetectApiKey = filter.getString("huaweiSafetyDetectApiKey") ?: ""
        val country = filter.getString("country") ?: "sa"

        Timber.d("Initializing TerminalSDK with country: $country")

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
            else -> Country.SA // Fallback
        }


        Timber.d("Initializing TerminalSDK with country: $sdkCountry")
        try {
            terminalSdk = TerminalSDK.Builder()
                .activity(activity!!)
                .environment(sdkEnvironment)
                .googleCloudProjectNumber(googleCloudProjectNumber)
                .huaweiSafetyDetectApiKey(huaweiSafetyDetectApiKey)
                .country(sdkCountry)
                .build()

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