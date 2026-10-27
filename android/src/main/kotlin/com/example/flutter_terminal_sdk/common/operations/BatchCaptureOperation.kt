package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.BatchCaptureResponse
import io.nearpay.terminalsdk.listeners.BatchCaptureListener
import io.nearpay.terminalsdk.listeners.failures.BatchCaptureFailure

class BatchCaptureOperation(provider: NearpayProvider) : BaseOperation(provider) {

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val settle = createSettler(response)

        val terminalUUID = filter.getString("terminalUUID")
            ?: return settle(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val terminal: Terminal =
            provider.terminalSdk?.getTerminal(provider.activity!!, terminalUUID)
                ?: return settle(
                    ResponseHandler.error(
                        "TERMINAL_NOT_FOUND",
                        "Terminal with uuid = $terminalUUID = not found"
                    )
                )

        try {
            terminal.batchCapture(object : BatchCaptureListener {
                override fun onBatchCaptureCompleted(batchCaptureResponse: BatchCaptureResponse) {
                    settle(
                        ResponseHandler.success(
                            "Batch capture completed",
                            mapOf("value" to batchCaptureResponse.value)
                        )
                    )
                }

                override fun onBatchCaptureFailure(batchCaptureFailure: BatchCaptureFailure) {
                    settle(
                        ResponseHandler.errorFromFailure(
                            "BATCH_CAPTURE_FAILURE",
                            batchCaptureFailure,
                            "Batch capture failed"
                        )
                    )
                }
            })
        } catch (e: Exception) {
            settle(
                ResponseHandler.errorFromFailure("BATCH_CAPTURE_FAILED", e, "Batch capture failed")
            )
        }
    }
}
