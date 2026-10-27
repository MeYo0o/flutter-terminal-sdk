package com.example.flutter_terminal_sdk.common.operations

import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import android.util.Base64
import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.filter.ArgsFilter
import com.example.flutter_terminal_sdk.common.status.ResponseHandler
import io.nearpay.terminalsdk.data.dto.TransactionResponse
import io.nearpay.terminalsdk.utils.BitmapListener
import io.nearpay.terminalsdk.utils.toImage
import kotlinx.coroutines.*
import kotlinx.serialization.json.*
import timber.log.Timber
import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicBoolean

class PrintMadaReceiptOperation(provider: NearpayProvider) : BaseOperation(provider) {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val mainHandler = Handler(Looper.getMainLooper())

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        coerceInputValues = true
        explicitNulls = false
    }

    override fun run(filter: ArgsFilter, response: (Map<String, Any>) -> Unit) {
        val activity = provider.activity
        if (activity == null) {
            mainHandler.post {
                response(ResponseHandler.error("NO_ACTIVITY", "Activity is null"))
            }
            return
        }

        val receiptPayload = filter.getString("receiptData")
        if (receiptPayload.isNullOrBlank()) {
            mainHandler.post {
                response(ResponseHandler.error("MISSING_RECEIPT_DATA", "Mada receipt payload is required"))
            }
            return
        }

        val receiptWidth = filter.getInt("receiptWidth") ?: 384
        val fontSize = filter.getInt("fontSize") ?: 1

        val unsupportedType = receiptTypeIfUnsupported(receiptPayload)
        if (unsupportedType != null) {
            mainHandler.post {
                response(
                    ResponseHandler.error(
                        "UNSUPPORTED_RECEIPT_PRINT",
                        "printMadaReceipt only renders MADA-shaped receipts (got $unsupportedType)."
                    )
                )
            }
            return
        }

        val receipt: TransactionResponse.Event.ReceiptData = try {
            json.decodeFromString(
                TransactionResponse.Event.ReceiptData.serializer(),
                receiptPayload
            )
        } catch (t: Throwable) {
            Timber.e(t, "Failed to decode MADA receipt payload")
            mainHandler.post {
                response(ResponseHandler.error("INVALID_RECEIPT", t.localizedMessage ?: "Invalid receipt payload"))
            }
            return
        }

        val replied = AtomicBoolean(false)
        fun replyOnce(map: Map<String, Any>) {
            if (replied.compareAndSet(false, true)) {
                mainHandler.post { response(map) }
            }
        }

        try {
            receipt.toImage(
                context = activity,
                receiptWidth = receiptWidth,
                fontSize = fontSize,
                listener = BitmapListener { bitmap ->
                    if (bitmap == null) {
                        replyOnce(ResponseHandler.error("PRINT_FAILED", "Failed to render MADA receipt: empty bitmap"))
                        return@BitmapListener
                    }
                    scope.launch {
                        try {
                            val base64 = bitmapToBase64(bitmap)
                            replyOnce(
                                ResponseHandler.success(
                                    message = "MADA receipt bitmap generated",
                                    data = mapOf("image" to base64)
                                )
                            )
                        } catch (t: Throwable) {
                            Timber.e(t, "PNG encoding failed")
                            replyOnce(ResponseHandler.error("PRINT_FAILED", t.localizedMessage ?: "PNG encoding failed"))
                        }
                    }
                }
            )
        } catch (t: Throwable) {
            Timber.e(t, "toImage() call failed")
            replyOnce(ResponseHandler.error("PRINT_FAILED", t.localizedMessage ?: "Failed to render MADA receipt"))
        }
    }

    private fun receiptTypeIfUnsupported(raw: String): String? {
        val obj = runCatching { json.parseToJsonElement(raw) as? JsonObject }.getOrNull() ?: return null
        val typeRaw = (obj["receiptType"] ?: obj["receipt_type"])
            ?.let { (it as? JsonPrimitive)?.contentOrNull }
            ?.trim()
            ?.uppercase()
            ?: return null
        val isPosLine = typeRaw == "MEPS" ||
            typeRaw == "POSLINE" ||
            typeRaw == "POS_LINE" ||
            typeRaw == "POS-LINE" ||
            (typeRaw.contains("POS") && typeRaw.contains("LINE"))
        return if (isPosLine) typeRaw else null
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val stream = ByteArrayOutputStream()
        if (!bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)) {
            throw IllegalStateException("Bitmap.compress returned false")
        }
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }
}
