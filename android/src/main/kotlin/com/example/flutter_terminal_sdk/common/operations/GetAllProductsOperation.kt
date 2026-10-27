package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class GetAllProductsOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val page = filter.getInt("page") ?: 1
        val limit = filter.getInt("limit") ?: 10

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        CashierReflectionInvoker.invokeWithPagination(
            terminal = terminal,
            methodName = "getAllProducts",
            page = page,
            limit = limit,
            failureCode = "GET_ALL_PRODUCTS_FAILURE",
            response = response
        )
    }
}
