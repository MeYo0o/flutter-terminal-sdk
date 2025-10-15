package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import timber.log.Timber

class IsWifiEnableOperation(provider: NearpayProvider) : BaseOperation(provider) {

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val isEnable = provider.isWifiEnabled() // return List<PermissionStatus>

        Timber.d("Wifi: $isEnable")

        response(ResponseHandler.success("Get Wifi status successfully", isEnable))

    }
}
