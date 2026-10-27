package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class CreateInvoiceOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val paramsJson = filter.getString("paramsJson")
            ?: return response(
                ResponseHandler.error("INVALID_PARAMS", "createInvoice requires paramsJson")
            )

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        CashierReflectionInvoker.invokeWithJsonParam(
            terminal = terminal,
            methodName = "createInvoice",
            paramsJson = paramsJson,
            failureCode = "CREATE_INVOICE_FAILURE",
            response = response
        )
    }
}
