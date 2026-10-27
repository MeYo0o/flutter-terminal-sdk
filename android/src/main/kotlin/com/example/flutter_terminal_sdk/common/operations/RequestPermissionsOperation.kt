package com.example.flutter_terminal_sdk.common.operations

import androidx.core.app.ActivityCompat
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class RequestPermissionsOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val activity = provider.activity
            ?: return response(ResponseHandler.error("NO_ACTIVITY", "Activity reference is null"))

        try {
            val missing = provider.checkRequiredPermissions()
                .filter { !it.isGranted }
                .map { it.permission }

            if (missing.isNotEmpty()) {
                ActivityCompat.requestPermissions(
                    activity,
                    missing.toTypedArray(),
                    PERMISSIONS_REQUEST_CODE
                )
            }

            response(ResponseHandler.success("Permissions requested"))
        } catch (e: Throwable) {
            response(
                ResponseHandler.errorFromFailure(
                    "PERMISSION_REQUEST_FAILED",
                    e,
                    e.message ?: "Failed to request permissions"
                )
            )
        }
    }

    companion object {
        private const val PERMISSIONS_REQUEST_CODE = 1001
    }
}
