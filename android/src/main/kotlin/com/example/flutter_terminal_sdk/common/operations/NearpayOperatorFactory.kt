import com.example.flutter_terminal_sdk.common.NearpayProvider
import com.example.flutter_terminal_sdk.common.operations.AuthorizeOperation
import com.example.flutter_terminal_sdk.common.operations.BaseOperation
import com.example.flutter_terminal_sdk.common.operations.BatchCaptureOperation
import com.example.flutter_terminal_sdk.common.operations.IsOperationSupportedOperation
import com.example.flutter_terminal_sdk.common.operations.CaptureAuthorizationOperation
import com.example.flutter_terminal_sdk.common.operations.CaptureAuthorizationWithTapOperation
import com.example.flutter_terminal_sdk.common.operations.CancelReadingOperation
import com.example.flutter_terminal_sdk.common.operations.CancelTransactionOperation
import com.example.flutter_terminal_sdk.common.operations.CheckRequiredPermissionsOperation
import com.example.flutter_terminal_sdk.common.operations.ConnectTerminalOperation
import com.example.flutter_terminal_sdk.common.operations.CreateInvoiceOperation
import com.example.flutter_terminal_sdk.common.operations.CreateProductOperation
import com.example.flutter_terminal_sdk.common.operations.CreateProxyRoomOperation
import com.example.flutter_terminal_sdk.common.operations.DeleteProductOperation
import com.example.flutter_terminal_sdk.common.operations.DisconnectTerminalOperation
import com.example.flutter_terminal_sdk.common.operations.DismissReaderUiOperation
import com.example.flutter_terminal_sdk.common.operations.GenerateQrCodeOperation
import com.example.flutter_terminal_sdk.common.operations.GetAllProductsOperation
import com.example.flutter_terminal_sdk.common.operations.GetInvoiceListOperation
import com.example.flutter_terminal_sdk.common.operations.GetInvoiceOperation
import com.example.flutter_terminal_sdk.common.operations.GetPendingTotalOperation
import com.example.flutter_terminal_sdk.common.operations.GetReconcileDetailsOperation
import com.example.flutter_terminal_sdk.common.operations.GetReconciliationListOperation
import com.example.flutter_terminal_sdk.common.operations.ToImageOperation
import com.example.flutter_terminal_sdk.common.operations.GetReconciliationOperation
import com.example.flutter_terminal_sdk.common.operations.GetTerminalConfigOperation
import com.example.flutter_terminal_sdk.common.operations.GetTerminalListOperation
import com.example.flutter_terminal_sdk.common.operations.GetTerminalOperation
import com.example.flutter_terminal_sdk.common.operations.GetIntentOperation
import com.example.flutter_terminal_sdk.common.operations.GetIntentListOperation
import com.example.flutter_terminal_sdk.common.operations.GetUserOperation
import com.example.flutter_terminal_sdk.common.operations.GetUsersOperation
import com.example.flutter_terminal_sdk.common.operations.IncrementAuthorizationOperation
import com.example.flutter_terminal_sdk.common.operations.InitializeOperation
import com.example.flutter_terminal_sdk.common.operations.InstallmentsOperation
import com.example.flutter_terminal_sdk.common.operations.IsNfcEnableOperation
import com.example.flutter_terminal_sdk.common.operations.IsTerminalReadyOperation
import com.example.flutter_terminal_sdk.common.operations.IsWifiEnableOperation
import com.example.flutter_terminal_sdk.common.operations.LogoutOperation
import com.example.flutter_terminal_sdk.common.operations.OpenRefundOperation
import com.example.flutter_terminal_sdk.common.operations.PrintMadaReceiptOperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseOperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseVoidOperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseWithQROperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseWithTipOperation
import com.example.flutter_terminal_sdk.common.operations.PurchaseWithTokenizationOperation
import com.example.flutter_terminal_sdk.common.operations.QrStatusOperation
import com.example.flutter_terminal_sdk.common.operations.QrVoidOperation
import com.example.flutter_terminal_sdk.common.operations.QrRefundOperation
import com.example.flutter_terminal_sdk.common.operations.ReconcileOperation
import com.example.flutter_terminal_sdk.common.operations.RefundOperation
import com.example.flutter_terminal_sdk.common.operations.RequestPermissionsOperation
import com.example.flutter_terminal_sdk.common.operations.RefundVoidOperation
import com.example.flutter_terminal_sdk.common.operations.RefundWithoutTapOperation
import com.example.flutter_terminal_sdk.common.operations.ReverseTransactionOperation
import com.example.flutter_terminal_sdk.common.operations.RoutingExecuteOperation
import com.example.flutter_terminal_sdk.common.operations.RoutingInstallmentsOperation
import com.example.flutter_terminal_sdk.common.operations.RoutingLookupOperation
import com.example.flutter_terminal_sdk.common.operations.RoutingProfileOperation
import com.example.flutter_terminal_sdk.common.operations.SendEmailOtpOperation
import com.example.flutter_terminal_sdk.common.operations.SendMobileOtpOperation
import com.example.flutter_terminal_sdk.common.operations.ShareInvoiceOperation
import com.example.flutter_terminal_sdk.common.operations.ShareReceiptOperation
import com.example.flutter_terminal_sdk.common.operations.ShareReceiptViaNfcOperation
import com.example.flutter_terminal_sdk.common.operations.StartShareUrlServiceOperation
import com.example.flutter_terminal_sdk.common.operations.StopReceiptViaNfcShareOperation
import com.example.flutter_terminal_sdk.common.operations.SupportsReceiptViaNfcOperation
import com.example.flutter_terminal_sdk.common.operations.TipTransactionOperation
import com.example.flutter_terminal_sdk.common.operations.VerifyEmailOtpOperation
import com.example.flutter_terminal_sdk.common.operations.VerifyJWTOperation
import com.example.flutter_terminal_sdk.common.operations.VerifyMobileOtpOperation
import com.example.flutter_terminal_sdk.common.operations.VoidAuthorizationOperation
import com.example.flutter_terminal_sdk.common.operations.VoidAuthorizationWithTapOperation

class NearpayOperatorFactory(private val provider: NearpayProvider) {
    private val operations: Map<String, BaseOperation> = mapOf(
        "initialize" to InitializeOperation(provider),
        "sendMobileOtp" to SendMobileOtpOperation(provider),
        "sendEmailOtp" to SendEmailOtpOperation(provider),
        "verifyMobileOtp" to VerifyMobileOtpOperation(provider),
        "verifyEmailOtp" to VerifyEmailOtpOperation(provider),
        "purchase" to PurchaseOperation(provider),
        "purchaseWithTokenization" to PurchaseWithTokenizationOperation(provider),
        "purchaseVoid" to PurchaseVoidOperation(provider),
        "refund" to RefundOperation(provider),
        "refundWithoutTap" to RefundWithoutTapOperation(provider),
        "refundVoid" to RefundVoidOperation(provider),
        "getTerminalList" to GetTerminalListOperation(provider),
        "connectTerminal" to ConnectTerminalOperation(provider),
        "getIntent" to GetIntentOperation(provider),
        "getIntentDetails" to GetIntentOperation(provider),
        "getIntentList" to GetIntentListOperation(provider),
        "getReconciliationList" to GetReconciliationListOperation(provider),
        "getReconcileList" to GetReconciliationListOperation(provider),
        "getReconciliation" to GetReconciliationOperation(provider),
        "getReconcileDetails" to GetReconcileDetailsOperation(provider),
        "reconcile" to ReconcileOperation(provider),
        "getUser" to GetUserOperation(provider),
        "getUsers" to GetUsersOperation(provider),
        "logout" to LogoutOperation(provider),
        "getTerminal" to GetTerminalOperation(provider),
        "jwtVerify" to VerifyJWTOperation(provider),
        "reverseTransaction" to ReverseTransactionOperation(provider),
        "checkRequiredPermissions" to CheckRequiredPermissionsOperation(provider),
        "requestPermissions" to RequestPermissionsOperation(provider),
        "isWifiEnabled" to IsWifiEnableOperation(provider),
        "isNfcEnabled" to IsNfcEnableOperation(provider),
        "authorize" to AuthorizeOperation(provider),
        "captureAuthorization" to CaptureAuthorizationOperation(provider),
        "voidAuthorization" to VoidAuthorizationOperation(provider),
        "voidAuthorizationWithTap" to VoidAuthorizationWithTapOperation(provider),
        "shareInvoice" to ShareInvoiceOperation(provider),
        "incrementAuthorization" to IncrementAuthorizationOperation(provider),
        "isTerminalReady" to IsTerminalReadyOperation(provider),
        "getPendingTotal" to GetPendingTotalOperation(provider),
        "batchCapture" to BatchCaptureOperation(provider),
        "isOperationSupported" to IsOperationSupportedOperation(provider),
        "getTerminalConfig" to GetTerminalConfigOperation(provider),
        "tipTransaction" to TipTransactionOperation(provider),
        "dismissReaderUi" to DismissReaderUiOperation(provider),
        "toImage" to ToImageOperation(provider),
        "printMadaReceipt" to PrintMadaReceiptOperation(provider),
        "openRefund" to OpenRefundOperation(provider),
        "captureAuthorizationWithTap" to CaptureAuthorizationWithTapOperation(provider),
        "purchaseWithTip" to PurchaseWithTipOperation(provider),
        "installments" to InstallmentsOperation(provider),
        "purchaseWithQR" to PurchaseWithQROperation(provider),
        "generateQrCode" to GenerateQrCodeOperation(provider),
        "qrStatus" to QrStatusOperation(provider),
        "qrVoid" to QrVoidOperation(provider),
        "qrRefund" to QrRefundOperation(provider),
        "getRoutingProfile" to RoutingProfileOperation(provider),
        "routingLookup" to RoutingLookupOperation(provider),
        "routingExecute" to RoutingExecuteOperation(provider),
        "routingInstallments" to RoutingInstallmentsOperation(provider),
        "createProxyRoom" to CreateProxyRoomOperation(provider),
        "createInvoice" to CreateInvoiceOperation(provider),
        "getInvoiceList" to GetInvoiceListOperation(provider),
        "getInvoice" to GetInvoiceOperation(provider),
        "shareReceipt" to ShareReceiptOperation(provider),
        "shareReceiptViaNfc" to ShareReceiptViaNfcOperation(provider),
        "startShareUrlService" to StartShareUrlServiceOperation(provider),
        "stopReceiptViaNfcShare" to StopReceiptViaNfcShareOperation(provider),
        "supportsReceiptViaNfc" to SupportsReceiptViaNfcOperation(provider),
        "createProduct" to CreateProductOperation(provider),
        "getAllProducts" to GetAllProductsOperation(provider),
        "deleteProduct" to DeleteProductOperation(provider),
        "disconnectTerminal" to DisconnectTerminalOperation(provider),
        "cancelReading" to CancelReadingOperation(provider),
        "cancelTransaction" to CancelTransactionOperation(provider),

    )

    fun getOperation(method: String): BaseOperation? {
        return operations[method]
    }
}
