package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler

class GetInvoiceOperation(provider: NearpayProvider) : BaseOperation(provider) {
    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val terminalUUID = filter.getString("terminalUUID")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val invoiceId = filter.getString("invoiceId")?.trim()
        if (invoiceId.isNullOrEmpty()) {
            return response(
                ResponseHandler.error("MISSING_INVOICE_ID", "invoiceId is required")
            )
        }

        val terminal =
            provider.activity?.let { provider.terminalSdk?.getTerminal(it, terminalUUID) }
                ?: return response(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        CashierReflectionInvoker.invokeWithStringParam(
            terminal = terminal,
            methodName = "getInvoice",
            value = invoiceId,
            failureCode = "GET_INVOICE_FAILURE",
            response = response
        )
    }
}
