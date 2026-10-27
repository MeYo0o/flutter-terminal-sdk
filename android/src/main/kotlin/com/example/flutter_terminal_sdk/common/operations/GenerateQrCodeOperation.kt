package com.example.flutter_terminal_sdk.common.operations

import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import com.example.flutter_terminal_sdk.common.toJsonMap
import com.google.gson.Gson
import io.nearpay.terminalsdk.Terminal
import io.nearpay.terminalsdk.data.dto.GeneratedQRCode
import io.nearpay.terminalsdk.data.dto.Location
import io.nearpay.terminalsdk.listeners.GenerateQrCodeListener
import io.nearpay.terminalsdk.listeners.failures.GenerateQrCodeFailure
import io.nearpay.terminalsdk.utils.NearpayException
import timber.log.Timber

class GenerateQrCodeOperation(provider: NearpayProvider) : BaseOperation(provider) {
    private val gson = Gson()

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val uuid = filter.getString("uuid")
            ?: return response(ResponseHandler.error("MISSING_UUID", "Terminal uuid is required"))

        val id = filter.getString("id")
            ?: return response(ResponseHandler.error("MISSING_ID", "ID is required"))

        val amount = filter.getString("amount")
            ?: filter.getLong("amount")?.toString()
            ?: return response(ResponseHandler.error("MISSING_AMOUNT", "Amount is required"))

        val customerReferenceNumber = filter.getString("customerReferenceNumber")
        val lat = filter.getDouble("lat")
        val long = filter.getDouble("long")
        val isLocationFromMock = filter.getBoolean("isLocationFromMock")
        val location = if (lat != null && long != null) {
            Location(long = long, lat = lat, isLocationFromMock = isLocationFromMock)
        } else {
            null
        }

        val terminal: Terminal = provider.terminalSdk?.getTerminal(provider.activity!!, uuid)
            ?: return response(
                ResponseHandler.error(
                    "TERMINAL_NOT_FOUND",
                    "Terminal with uuid = $uuid = not found"
                )
            )

        try {
            terminal.generateQrCode(
                intentId = id,
                amount = amount,
                location = location,
                customerReferenceNumber = customerReferenceNumber,
                generateQrCodeListener = object : GenerateQrCodeListener {
                    override fun onGenerateQrCodeSuccess(qrCode: GeneratedQRCode) {
                        val map = gson.toJsonMap(qrCode)?.toMutableMap()
                        if (map == null) {
                            response(
                                ResponseHandler.error(
                                    "SERIALIZE_FAILED",
                                    "Failed to serialize QR code"
                                )
                            )
                        } else {
                            map["responseType"] = "GenerateQrCode"
                            response(ResponseHandler.success("QR code generated", map))
                        }
                    }

                    override fun onNearpayException(nearPayException: NearpayException) {
                        response(
                            ResponseHandler.errorFromFailure(
                                "GENERATE_QR_CODE_FAILURE",
                                nearPayException,
                                "Generate QR code failed"
                            )
                        )
                    }

                    override fun onGenerateQrCodeFailure(generateQrCodeFailure: GenerateQrCodeFailure) {}
                }
            )
        } catch (e: Exception) {
            Timber.tag("GenerateQrCodeOperation").e(e, "Generate QR code failed")
            response(
                ResponseHandler.errorFromFailure(
                    "GENERATE_QR_CODE_FAILED",
                    e,
                    "Generate QR code failed: ${e.message}"
                )
            )
        }
    }
}
