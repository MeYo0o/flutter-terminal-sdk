package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import timber.log.Timber

class GetUsersOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {

        val userList = provider.terminalSdk?.getUsers() ?: return response(
            ResponseHandler.error("INVALID_USERS", "No users found")
        )

        val mMap =
            mutableMapOf<String, Map<String, String?>>()

        for (user in userList) {
            Timber.d("first loop user uuid: ${user.first}")
            Timber.d("first loop user name: ${user.second}")

            val simpleUser = mapOf(
                "userUUID" to user.first,
                "name" to user.second,
            )

            mMap[user.first ?: "unknown"] = simpleUser
        }

        response(ResponseHandler.success("Users fetched successfully: $userList", mMap))

    }
}
