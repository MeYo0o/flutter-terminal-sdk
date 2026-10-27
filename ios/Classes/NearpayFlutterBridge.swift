import Foundation
import Security
import SwiftUI
import UIKit
import DeviceKit
import TerminalSDK
import Flutter

private typealias SDKConfiguration = TerminalSDK.TerminalSDKConfiguration
private typealias TerminalPINEntryView = TerminalSDK.PINEntryView
private typealias TerminalAuthenticator = TerminalSDK.Authenticator
private typealias TerminalAuthenticationMethod = TerminalSDK.AuthenticationMethod
private typealias ReaderPaymentCardScheme = TerminalSDK.PaymentCardScheme
private typealias TerminalLinkingRequestHandler = TerminalSDK.ReaderLinkingHandler
private typealias TerminalLinkingResult = TerminalSDK.ReaderLinkingResult
private typealias AppleLinkingState = TerminalSDK.AppleLinkingState

final class NearpayFlutterBridge {

  private let methodChannel: FlutterMethodChannel

  init(methodChannel: FlutterMethodChannel) {
    self.methodChannel = methodChannel
  }

  func attachMethodChannel(_ channel: FlutterMethodChannel) {
    _ = channel
  }

  private static let installationFlagKey = "NearpayTerminalSDKInstallationFlag"

  private enum Event: String, CaseIterable {
    case purchaseEvent = "purchaseEvent"
    case purchaseWithTipEvent = "purchaseWithTipEvent"
    case refundEvent = "refundEvent"
    case openRefundEvent = "openRefundEvent"
    case purchaseVoidEvent = "purchaseVoidEvent"
    case refundVoidEvent = "refundVoidEvent"
    case installmentsEvent = "installmentsEvent"
    case routingLookupEvent = "RoutingLookupEvent"
    case authEvent = "authEvent"
    case captureAuthorizationWithTapEvent = "captureAuthorizationWithTapEvent"
    case voidAuthorizationWithTapEvent = "voidAuthorizationWithTapEvent"
    case terminalLinkingEvent = "terminalLinkingEvent"
    case qrPaymentEvent = "purchaseWithQREvent"
    case qrVoidEvent = "qrVoidEvent"
    case qrRefundEvent = "qrRefundEvent"
  }

  private enum LinkingOperation: String {
    case connectTerminal
    case getTerminal
  }

    private var terminalInterface: TerminalInterface?
  private var currentAuthentication: TerminalAuthenticator?
  private var currentUser: NearpayUser? {
    didSet {
      guard let user = currentUser else { return }
      user.onLogout = { [weak self] userId in
        self?.handleLogout(userId: userId)
      }
      user.onTerminalDisconnect = { [weak self] terminalId in
        self?.handleTerminalDisconnect(terminalId: terminalId)
      }
    }
  }
  private var currentTerminal: NearpayTerminal? {
    didSet {
      currentTerminal?.onDisconnect = { [weak self] terminalId in
        self?.handleTerminalDisconnect(terminalId: terminalId)
      }
    }
  }
  private var pinEntryHostingController: UIHostingController<TerminalPINEntryView>?
  private var qrPaymentHostingController: UIHostingController<QrPaymentHostRoot>?
  private var qrPaymentUiListeners: [String: QrPaymentUiListener] = [:]
  private var qrVoidListeners: [String: QrVoidListener] = [:]
  private var qrRefundListeners: [String: QrRefundListener] = [:]
  private var routingSessions: [String: TerminalSDK.RoutingSession] = [:]
  private typealias OperationHandler = (
    _ args: NSDictionary?,
    _ resolve: @escaping FlutterResult,
    _ reject: @escaping FlutterResult
  ) -> Void
  private func op(
    _ body: @escaping (
      _ bridge: NearpayFlutterBridge,
      _ args: NSDictionary?,
      _ resolve: @escaping FlutterResult,
      _ reject: @escaping FlutterResult
    ) -> Void
  ) -> OperationHandler {
    { [weak self] args, resolve, reject in
      guard let self else {
        resolve(Self.settledModuleReleasedResponse())
        return
      }
      body(self, args, resolve, reject)
    }
  }
  private lazy var operations: [String: OperationHandler] = {
    [
      "jwtVerify": op { bridge, args, resolve, reject in bridge.jwtVerify(args ?? [:], resolver: resolve, rejecter: reject) },
      "sendMobileOtp": op { bridge, args, resolve, reject in bridge.sendMobileOtp(args ?? [:], resolver: resolve, rejecter: reject) },
      "sendEmailOtp": op { bridge, args, resolve, reject in bridge.sendEmailOtp(args ?? [:], resolver: resolve, rejecter: reject) },
      "verifyMobileOtp": op { bridge, args, resolve, reject in bridge.verifyMobileOtp(args ?? [:], resolver: resolve, rejecter: reject) },
      "verifyEmailOtp": op { bridge, args, resolve, reject in bridge.verifyEmailOtp(args ?? [:], resolver: resolve, rejecter: reject) },
      "getUser": op { bridge, args, resolve, reject in bridge.getUser(args ?? [:], resolver: resolve, rejecter: reject) },
      "getTerminal": op { bridge, args, resolve, reject in bridge.getTerminal(args ?? [:], resolver: resolve, rejecter: reject) },
      "authenticator": op { bridge, args, resolve, reject in bridge.authenticator(args ?? [:], resolver: resolve, rejecter: reject) },
      "getTerminalList": op { bridge, args, resolve, reject in bridge.getTerminalList(args ?? [:], resolver: resolve, rejecter: reject) },
      "connectTerminal": op { bridge, args, resolve, reject in bridge.connectTerminal(args ?? [:], resolver: resolve, rejecter: reject) },
      "disconnectTerminal": op { bridge, _, resolve, reject in bridge.disconnectTerminal(resolve, rejecter: reject) },
      "logout": op { bridge, _, resolve, reject in bridge.logout(resolve, rejecter: reject) },
      "purchase": op { bridge, args, resolve, reject in bridge.purchase(args ?? [:], resolver: resolve, rejecter: reject) },
      "purchaseWithTokenization": op { bridge, args, resolve, reject in bridge.purchaseWithTokenization(args ?? [:], resolver: resolve, rejecter: reject) },
      "purchaseWithTip": op { bridge, args, resolve, reject in bridge.purchaseWithTip(args ?? [:], resolver: resolve, rejecter: reject) },
      "installments": op { bridge, args, resolve, reject in bridge.installments(args ?? [:], resolver: resolve, rejecter: reject) },
      "purchaseVoid": op { bridge, args, resolve, reject in bridge.purchaseVoid(args ?? [:], resolver: resolve, rejecter: reject) },
      "refund": op { bridge, args, resolve, reject in bridge.refund(args ?? [:], resolver: resolve, rejecter: reject) },
      "refundWithoutTap": op { bridge, args, resolve, reject in bridge.refundWithoutTap(args ?? [:], resolver: resolve, rejecter: reject) },
      "openRefund": op { bridge, args, resolve, reject in bridge.openRefund(args ?? [:], resolver: resolve, rejecter: reject) },
      "refundVoid": op { bridge, args, resolve, reject in bridge.refundVoid(args ?? [:], resolver: resolve, rejecter: reject) },
      "authorize": op { bridge, args, resolve, reject in bridge.authorize(args ?? [:], resolver: resolve, rejecter: reject) },
      "captureAuthorizationWithTap": op { bridge, args, resolve, reject in bridge.captureAuthorizationWithTap(args ?? [:], resolver: resolve, rejecter: reject) },
      "voidAuthorizationWithTap": op { bridge, args, resolve, reject in bridge.voidAuthorizationWithTap(args ?? [:], resolver: resolve, rejecter: reject) },
      "shareInvoice": op { bridge, _, resolve, _ in bridge.resolveUnsupported("shareInvoice", resolver: resolve) },
      "shareReceiptViaNfc": op { bridge, _, resolve, _ in bridge.resolveUnsupported("shareReceiptViaNfc", resolver: resolve) },
      "startShareUrlService": op { bridge, _, resolve, _ in bridge.resolveUnsupported("startShareUrlService", resolver: resolve) },
      "stopReceiptViaNfcShare": op { bridge, _, resolve, _ in bridge.resolveUnsupported("stopReceiptViaNfcShare", resolver: resolve) },
      "supportsReceiptViaNfc": op { bridge, _, resolve, _ in bridge.resolveUnsupported("supportsReceiptViaNfc", resolver: resolve) },
      "cancelTransaction": op { bridge, args, resolve, reject in bridge.cancelTransaction(args ?? [:], resolver: resolve, rejecter: reject) },
      "reverseTransaction": op { bridge, args, resolve, reject in bridge.reverseTransaction(args ?? [:], resolver: resolve, rejecter: reject) },
      "capture": op { bridge, args, resolve, reject in bridge.capture(args ?? [:], resolver: resolve, rejecter: reject) },
      "increment": op { bridge, args, resolve, reject in bridge.increment(args ?? [:], resolver: resolve, rejecter: reject) },
      "tipTransaction": op { bridge, args, resolve, reject in bridge.tipTransaction(args ?? [:], resolver: resolve, rejecter: reject) },
      "voidAuthorization": op { bridge, args, resolve, reject in bridge.voidAuthorization(args ?? [:], resolver: resolve, rejecter: reject) },
      "reconcile": op { bridge, _, resolve, reject in bridge.reconcile(resolve, rejecter: reject) },
      "getReconcileList": op { bridge, args, resolve, reject in bridge.getReconcileList(args, resolver: resolve, rejecter: reject) },
      "getReconcileDetails": op { bridge, args, resolve, reject in bridge.getReconcileDetails(args, resolver: resolve, rejecter: reject) },
      "getIntentList": op { bridge, args, resolve, reject in bridge.getIntentList(args, resolver: resolve, rejecter: reject) },
      "getIntentDetails": op { bridge, args, resolve, reject in bridge.getIntentDetails(args, resolver: resolve, rejecter: reject) },
      "getReconciliation": op { bridge, args, resolve, reject in bridge.getReconciliation(args, resolver: resolve, rejecter: reject) },
      "getPendingTotal": op { bridge, args, resolve, reject in bridge.getPendingTotal(args, resolver: resolve, rejecter: reject) },
      "createInvoice": op { bridge, args, resolve, reject in bridge.createInvoice(args, resolver: resolve, rejecter: reject) },
      "getInvoiceList": op { bridge, args, resolve, reject in bridge.getInvoiceList(args, resolver: resolve, rejecter: reject) },
      "createProduct": op { bridge, args, resolve, reject in bridge.createProduct(args, resolver: resolve, rejecter: reject) },
      "getAllProducts": op { bridge, args, resolve, reject in bridge.getAllProducts(args, resolver: resolve, rejecter: reject) },
      "getProduct": op { bridge, args, resolve, reject in bridge.getProduct(args, resolver: resolve, rejecter: reject) },
      "deleteProduct": op { bridge, args, resolve, reject in bridge.deleteProduct(args, resolver: resolve, rejecter: reject) },
      "getInvoice": op { bridge, args, resolve, reject in bridge.getInvoice(args, resolver: resolve, rejecter: reject) },
      "shareReceipt": op { bridge, args, resolve, reject in bridge.shareReceipt(args, resolver: resolve, rejecter: reject) },
      "generateQrCode": op { bridge, args, resolve, reject in bridge.generateQrCode(args, resolver: resolve, rejecter: reject) },
      "qrStatus": op { bridge, args, resolve, reject in bridge.qrStatus(args, resolver: resolve, rejecter: reject) },
      "generateQrCodeWithUi": op { bridge, args, resolve, reject in bridge.generateQrCodeWithUi(args, resolver: resolve, rejecter: reject) },
      "qrVoid": op { bridge, args, resolve, reject in bridge.qrVoid(args ?? [:], resolver: resolve, rejecter: reject) },
      "qrRefund": op { bridge, args, resolve, reject in bridge.qrRefund(args ?? [:], resolver: resolve, rejecter: reject) },
      "getTerminalConfig": op { bridge, args, resolve, reject in bridge.getTerminalConfig(args, resolver: resolve, rejecter: reject) },
      "printMadaReceipt": op { bridge, _, resolve, _ in bridge.resolveUnsupported("printMadaReceipt", resolver: resolve) },
      "dismissReaderUi": op { bridge, _, resolve, _ in bridge.dismissReaderUi(resolver: resolve) },
      "cancelReading": op { bridge, _, resolve, _ in bridge.cancelReading(resolver: resolve) },

      "incrementAuthorization": op { bridge, args, resolve, reject in bridge.operations["increment"]?(args, resolve, reject) },
      "captureAuthorization": op { bridge, args, resolve, reject in bridge.operations["capture"]?(args, resolve, reject) },
      "getUsers": op { bridge, _, resolve, _ in bridge.resolveUnsupported("getUsers", resolver: resolve) },
      "isTerminalReady": op { bridge, args, resolve, _ in bridge.isTerminalReady(args, resolver: resolve) },
      "checkRequiredPermissions": op { bridge, _, resolve, _ in bridge.checkRequiredPermissions(resolver: resolve) },
      "isNfcEnabled": op { bridge, _, resolve, _ in bridge.isNfcEnabled(resolver: resolve) },
      "isWifiEnabled": op { bridge, _, resolve, _ in bridge.isWifiEnabled(resolver: resolve) },
      "toImage": op { bridge, _, resolve, _ in bridge.resolveUnsupported("toImage", resolver: resolve) },
      "getRoutingProfile": op { bridge, _, resolve, reject in bridge.getRoutingProfile(resolve, rejecter: reject) },
      "routingLookup": op { bridge, args, resolve, reject in bridge.routingLookup(args ?? [:], resolver: resolve, rejecter: reject) },
      "routingExecute": op { bridge, args, resolve, reject in bridge.routingExecute(args ?? [:], resolver: resolve, rejecter: reject) },
      "routingInstallments": op { bridge, args, resolve, reject in bridge.routingInstallments(args ?? [:], resolver: resolve, rejecter: reject) },
      "batchCapture": op { bridge, args, resolve, reject in bridge.batchCapture(args ?? [:], resolver: resolve, rejecter: reject) },
      "isOperationSupported": op { bridge, args, resolve, reject in bridge.isOperationSupported(args ?? [:], resolver: resolve, rejecter: reject) },
      "createProxyRoom": op { bridge, _, resolve, _ in bridge.resolveUnsupported("createProxyRoom", resolver: resolve) },
      "purchaseWithQR": op { bridge, args, resolve, reject in bridge.generateQrCodeWithUi(args, resolver: resolve, rejecter: reject) },
    ]
  }()

  func initialize(
    _ configuration: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    ensureKeychainResetIfNeeded()

    DispatchQueue.main.async {
      let sdkConfiguration = self.parseSDKConfiguration(from: configuration)
      self.terminalInterface = TerminalInterface(
        sdkConfiguration,
        onLogout: { [weak self] userId in
          self?.handleLogout(userId: userId)
        },
        onTerminalDisconnect: { [weak self] terminalId in
          self?.handleTerminalDisconnect(terminalId: terminalId)
        }
      )

      self.currentAuthentication = nil
      self.currentUser = nil
      self.currentTerminal = nil

      self.emitInitializationEvent(status: "success", message: nil)
      resolve("Initialization successful")
    }
  }

  func requestPermissions(
    _ resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    resolve(true)
  }

  func verifyNfcAndWifi(
    _ resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    resolve(true)
  }

  private func normalizeBridgeOperationArgs(_ args: NSDictionary?) -> NSDictionary {
    RequestParser.normalizeBridgeOperationArgs(args)
  }

  func executeOperation(
    _ method: String,
    args: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let operation = operations[method] else {
      resolve(responseHandlerError(code: "UNSUPPORTED_OPERATION", message: "Method \(method) is not implemented."))
      return
    }

    let normalizedArgs = normalizeBridgeOperationArgs(args)
    operation(normalizedArgs, resolve, reject)
  }

  func excuteOperation(
    _ method: String,
    args: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    executeOperation(method, args: args, resolver: resolve, rejecter: reject)
  }

  func excuteOpertation(
    _ method: String,
    args: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    executeOperation(method, args: args, resolver: resolve, rejecter: reject)
  }

  func login(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let interface = terminalInterface else {
      rejectPromise(reject, error: BridgeError.notInitialized)
      return
    }

    guard
      let dictionary = params as? [String: Any],
      let typeRaw = (dictionary["type"] as? String)?.lowercased(),
      let value = dictionary["value"] as? String,
      !value.isEmpty
    else {
      rejectPromise(reject, error: BridgeError.missingParameter("type/value"))
      return
    }

    let method: LoginMethod
    let authMethod: TerminalAuthenticationMethod?
    switch typeRaw {
    case "mobile":
      method = .mobile(value)
      authMethod = .mobile(value)
    case "email":
      method = .email(value)
      authMethod = .email(value)
    case "jwt":
      method = .jwt(value)
      authMethod = nil
    default:
      rejectPromise(reject, error: BridgeError.invalidParameter("type"))
      return
    }

    let authentication = authMethod.map { interface.authenticator(with: $0) }
    currentAuthentication = authentication

    DispatchQueue.main.async {
      interface.login(with: method) { [weak self, authentication] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let objects):
            self.currentAuthentication = objects.authenticator ?? authentication
            if let user = objects.user {
              self.currentUser = user
            }
            if let terminal = objects.terminal {
              self.currentTerminal = terminal
            }
            resolve(self.serializeAuthenticationObjects(objects))
          case .failure(let error):
            self.currentAuthentication = nil
            self.rejectPromise(reject, error: error)
          }
        }
      }
    }
  }

  func sendOTP(
    _ resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let authentication = currentAuthentication else {
      rejectPromise(reject, error: TerminalError.invalidRequest(.userLoggedOut))
      return
    }

    DispatchQueue.main.async {
      authentication.sendOTP { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            resolve(true)
          case .failure(let error):
            self.rejectPromise(reject, error: error)
          }
        }
      }
    }
  }

  func verifyOTP(
    _ otp: String,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let authentication = currentAuthentication else {
      rejectPromise(reject, error: TerminalError.invalidRequest(.userLoggedOut))
      return
    }

    DispatchQueue.main.async {
      authentication.verify(otp: otp) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let user):
            self.currentUser = user
            resolve(self.serializeUser(user))
          case .failure(let error):
            self.rejectPromise(reject, error: error)
          }
        }
      }
    }
  }

  func getConfig(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    getTerminalConfig(params, resolver: resolve, rejecter: reject)
  }

  func checkRequiredPermissions(resolver resolve: @escaping FlutterResult) {
    resolve(responseHandlerSuccess(message: BridgeMessages.permissionsChecked, data: []))
  }

  func isNfcEnabled(resolver resolve: @escaping FlutterResult) {
    resolve(responseHandlerSuccess(message: BridgeMessages.nfcStatus, data: true))
  }

  func isWifiEnabled(resolver resolve: @escaping FlutterResult) {
    resolve(responseHandlerSuccess(message: BridgeMessages.wifiStatus, data: true))
  }

  func isTerminalReady(_ params: NSDictionary?, resolver resolve: @escaping FlutterResult) {
    guard let terminalIdString = stringValue(from: params?["terminalUUID"] ?? params?["terminalId"] ?? params?["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_UUID", message: BridgeMessages.missingTerminalUUID))
      return
    }

    guard let terminalId = UUID(uuidString: terminalIdString) else {
      resolve(responseHandlerError(code: "INVALID_UUID", message: BridgeMessages.invalidUUID(terminalIdString)))
      return
    }

    if let current = currentTerminal, current.id == terminalId {
      resolve(responseHandlerSuccess(
        message: BridgeMessages.terminalReadyStatus,
        data: ["isReady": current.isReady]
      ))
      return
    }

    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return
    }

    guard let terminal = interface.terminal(with: terminalId, readerLinkingHandler: nil) else {
      resolve(responseHandlerError(code: "INVALID_TERMINAL", message: BridgeMessages.terminalNotFound))
      return
    }

    currentTerminal = terminal
    resolve(responseHandlerSuccess(
      message: BridgeMessages.terminalReadyStatus,
      data: ["isReady": terminal.isReady]
    ))
  }

  private func mapFlutterEventType(_ type: String, event: Event) -> String {
    switch (event, type) {
    case (.purchaseEvent, "onSendTransactionCompleted"):
      return "sendPurchaseTransactionCompleted"
    case (.purchaseWithTipEvent, "onSendTransactionCompleted"):
      return "sendPurchaseWithTipTransactionCompleted"
    case (.refundEvent, "onSendTransactionCompleted"):
      return "sendRefundTransactionCompleted"
    case (.openRefundEvent, "onSendTransactionCompleted"):
      return "sendOpenRefundTransactionCompleted"
    case (.authEvent, "authorizeSuccess"):
      return "authorizeCompleted"
    case (.purchaseVoidEvent, "onSendTransactionCompleted"),
         (.refundVoidEvent, "onSendTransactionCompleted"):
      return "sendTransactionVoidCompleted"
    case (.installmentsEvent, "onSendTransactionCompleted"):
      return "sendInstallmentsTransactionCompleted"
    case (.captureAuthorizationWithTapEvent, "onSendTransactionCompleted"),
         (.captureAuthorizationWithTapEvent, "onCaptureAuthorizationWithTapCompleted"):
      return "captureWithTapCompleted"
    case (.voidAuthorizationWithTapEvent, "onSendTransactionCompleted"),
         (.voidAuthorizationWithTapEvent, "onVoidAuthorizationWithTapCompleted"):
      return "voidWithTapCompleted"
    case (.qrPaymentEvent, "onQrUiPresented"):
      return "qrUiPresented"
    case (.qrPaymentEvent, "onUiClosed"):
      return "uiClosed"
    case (.qrPaymentEvent, "onQrPaymentFailure"):
      return "qrPaymentFailure"
    case (.qrPaymentEvent, "onQrPaymentStatusUpdated"):
      return "qrPaymentStatusUpdated"
    case (.qrPaymentEvent, "onQrPaymentStatusCompleted"):
      return "qrPaymentStatusCompleted"
    case (.qrPaymentEvent, "onQrPaymentStatusFailed"):
      return "qrPaymentStatusFailed"
    case (.qrPaymentEvent, "onQrPaymentStatusExpired"):
      return "qrPaymentStatusExpired"
    case (.qrPaymentEvent, "onQrPaymentStatusCancelled"):
      return "qrPaymentStatusCancelled"
    case (_, "sendTransactionFailure"):
      return "sendTransactionFailure"
    case (_, "authorizeFailure"):
      return "authorizeFailure"
    default:
      return type
    }
  }

  private func flutterChannelName(for event: Event) -> String {
    event.rawValue
  }

  private func flutterEncodeValue(_ value: Any?) -> Any {
    switch value {
    case let dict as [String: Any]:
      return NSDictionary(dictionary: dict.mapValues { flutterEncodeValue($0) })
    case let dict as NSDictionary:
      return dict
    case let array as [Any]:
      return NSArray(array: array.map { flutterEncodeValue($0) })
    case let array as NSArray:
      return array
    default:
      return value ?? NSNull()
    }
  }

  private func flutterEncodeArguments(_ arguments: [String: Any]?) -> Any? {
    guard let arguments else { return nil }
    return flutterEncodeValue(arguments)
  }

  private func emitFlutterMethod(_ method: String, arguments: [String: Any]?) {
    #if DEBUG
    if let type = arguments?["type"] as? String {
      NSLog("[NearpayFlutterBridge] emit \(method) type=\(type)")
    } else {
      NSLog("[NearpayFlutterBridge] emit \(method)")
    }
    #endif
    DispatchQueue.main.async { [methodChannel] in
      let payload = self.flutterEncodeArguments(arguments)
      methodChannel.invokeMethod(method, arguments: payload) { result in
        #if DEBUG
        if let error = result as? FlutterError {
          NSLog(
            "[NearpayFlutterBridge] invokeMethod \(method) failed: \(error.message ?? "unknown")"
          )
        }
        #endif
      }
    }
  }

  private func flutterFlatReconciliationPayload(_ receipt: ReconciliationReceipt?) -> [String: Any]? {
    guard let receipt else { return nil }
    guard let payload = serializeReconciliationReceipt(receipt) else { return nil }
    return ResponseSerializer.camelCaseKeysDeep(payload) as? [String: Any]
  }

  private func flutterTopViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = (scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)
      ?? scenes.first as? UIWindowScene
    let keyWindow = windowScene?.windows.first(where: { $0.isKeyWindow })
      ?? windowScene?.windows.first
    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  private func resolveUnsupported(_ method: String, resolver resolve: @escaping FlutterResult) {
    resolve(responseHandlerError(code: "UNSUPPORTED_OPERATION", message: BridgeMessages.unsupported(method)))
  }

  private func dismissReaderUi(resolver resolve: @escaping FlutterResult) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    dismissPinEntryView()
    terminal.dismissReaderUi()
    resolve(responseHandlerSuccess(
      message: BridgeMessages.readerUIDismissed,
      data: ["responseType": "DismissReaderUi"]
    ))
  }

  private func cancelReading(resolver resolve: @escaping FlutterResult) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    dismissPinEntryView()
    terminal.cancelReading()
    resolve(responseHandlerSuccess(
      message: BridgeMessages.readingCancelled,
      data: ["responseType": "CancelReading"]
    ))
  }

  private func emitInitializationEvent(status: String, message: String?) {
    if status == "success" {
      emitFlutterMethod("onSdkInitialized", arguments: nil)
      return
    }
    emitFlutterMethod(
      "onSdkInitializationFailed",
      arguments: ["error": message ?? "Initialization failed"]
    )
  }

  private func emitTransactionEvent(
    _ event: Event,
    intentId: UUID,
    type: String,
    message: String? = nil,
    data: Any? = nil
  ) {
    let mappedType = mapFlutterEventType(type, event: event)
    var body: [String: Any] = [
      "type": mappedType,
      "transactionUUID": intentId.uuidString,
      "transactionUuid": intentId.uuidString,
    ]
    if event == .authEvent {
      body["intentUUID"] = intentId.uuidString
      body["intentUuid"] = intentId.uuidString
    } else {
      body["intentUUID"] = intentId.uuidString
    }
    if event == .captureAuthorizationWithTapEvent || event == .voidAuthorizationWithTapEvent {
      body["uuid"] = intentId.uuidString
      body["authorizationUuid"] = intentId.uuidString
      body["authorizationUUID"] = intentId.uuidString
    }
    if let message {
      body["message"] = message
    }
    if let data {
      body["data"] = flutterEncodeValue(data)
    }
    emitFlutterMethod(flutterChannelName(for: event), arguments: body)
  }

  private func emitQrVoidEvent(
    requestId: String,
    type: String,
    message: String? = nil,
    data: Any? = nil
  ) {
    var body: [String: Any] = [
      "requestId": requestId,
      "type": type
    ]
    if let message {
      body["message"] = message
    }
    if let data {
      body["data"] = flutterEncodeValue(data)
    }
    emitFlutterMethod(flutterChannelName(for: .qrVoidEvent), arguments: body)
  }

  private func emitQrRefundEvent(
    requestId: String,
    type: String,
    message: String? = nil,
    data: Any? = nil
  ) {
    var body: [String: Any] = [
      "requestId": requestId,
      "type": type
    ]
    if let message {
      body["message"] = message
    }
    if let data {
      body["data"] = flutterEncodeValue(data)
    }
    emitFlutterMethod(flutterChannelName(for: .qrRefundEvent), arguments: body)
  }

  private func emitQrPaymentEvent(
    requestId: String,
    type: String,
    message: String? = nil,
    data: Any? = nil
  ) {
    let mappedType = mapFlutterEventType(type, event: .qrPaymentEvent)
    var body: [String: Any] = [
      "intentUUID": requestId,
      "type": mappedType
    ]
    if let message {
      body["message"] = message
    }
    if let data {
      body["data"] = flutterEncodeValue(data)
    }
    emitFlutterMethod(flutterChannelName(for: .qrPaymentEvent), arguments: body)
  }

  private func emitTerminalLinkingEvent(
    operation: LinkingOperation,
    terminalId: UUID,
    type: String,
    message: String? = nil,
    data: Any? = nil
  ) {
    var body: [String: Any] = [
      "operation": operation.rawValue,
      "terminalUUID": terminalId.uuidString,
      "terminalUuid": terminalId.uuidString,
      "type": type
    ]

    if let message {
      body["message"] = message
    }

    if let data {
      body["data"] = flutterEncodeValue(data)
    }

    emitFlutterMethod(Event.terminalLinkingEvent.rawValue, arguments: body)
  }

  private func handleLinkingResult(
    _ result: TerminalLinkingResult,
    emitter: (_ type: String, _ message: String?, _ data: [String: Any]?) -> Void
  ) {
    switch result {
    case .success(let response):
      switch response {
      case .nearpay(let state):
        handleNearpayLinkingState(state, emitter: emitter)
      case .apple(let state):
        handleAppleLinkingState(state, emitter: emitter)
      }
    case .failure(let error):
      let message = errorMessage(from: error)
      emitter(
        "linkingFailure",
        message,
        ["nativeError": serializeNativeError(error, code: "LINKING_FAILURE", message: message)]
      )
    }
  }

  private func handleNearpayLinkingState(
    _ state: TerminalSDK.NearpayLinkingState,
    emitter: (_ type: String, _ message: String?, _ data: [String: Any]?) -> Void
  ) {
    switch state {
    case .preparingToLink:
      emitter("preparingToLink", nil, ["provider": "nearpay", "state": "preparingToLink"])
    case .linkingStarted:
      emitter("linkingStarted", nil, ["provider": "nearpay", "state": "linkingStarted"])
    case .linkingCompleted:
      emitter("linkingCompleted", nil, ["provider": "nearpay", "state": "linkingCompleted"])
    @unknown default:
      break
    }
  }

  private func handleAppleLinkingState(
    _ state: AppleLinkingState,
    emitter: (_ type: String, _ message: String?, _ data: [String: Any]?) -> Void
  ) {
    switch state {
    case .preparingToLink:
      emitter("preparingToLink", nil, ["provider": "apple", "state": "preparingToLink"])
    case .linkingStarted:
      emitter("linkingStarted", nil, ["provider": "apple", "state": "linkingStarted"])
    case .linkingProgress(let progress):
      emitter(
        "linkingProgress",
        nil,
        [
          "provider": "apple",
          "progress": progress,
          "state": "linkingProgress",
        ]
      )
    case .linkingCompleted:
      emitter("linkingCompleted", nil, ["provider": "apple", "state": "linkingCompleted"])
    @unknown default:
      break
    }
  }

  private func startTransaction(
    intentId: UUID,
    event: Event,
    successType: String,
    failureType: String,
    start: @escaping (
      _ linkingHandler: @escaping TerminalLinkingRequestHandler,
      _ readingHandler: @escaping TerminalSDK.ReadingHandler,
      _ completion: @escaping TransactionRequestHandler
    ) -> Void,
    resolver resolve: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      let linkingHandler: TerminalLinkingRequestHandler = { [weak self] result in
        guard let self else { return }
        self.handleLinkingResult(result) { type, message, data in
          self.emitTransactionEvent(
            event,
            intentId: intentId,
            type: type,
            message: message,
            data: data
          )
        }
      }
      let readingHandler: TerminalSDK.ReadingHandler = { [weak self] result in
        DispatchQueue.main.async {
          guard let self else { return }
          self.handleReadingResult(result, event: event, intentId: intentId)
        }
      }
      let completion: TransactionRequestHandler = { [weak self] result in
        self?.handleTransactionResult(
          result,
          event: event,
          intentId: intentId,
          successType: successType,
          failureType: failureType
        )
      }

      start(linkingHandler, readingHandler, completion)
      resolve(self.responseHandlerSuccess(message: BridgeMessages.transactionStarted))
    }
  }

  private func handleReadingResult(
    _ result: TerminalSDK.ReadingResult,
    event: Event,
    intentId: UUID
  ) {
    switch result {
    case .success(let state):
      switch state {
      case .apple(let appleState):
        switch appleState {
        case .event(let readingEvent):
          guard let readingEvent else { return }
          switch readingEvent {
          case .notReady, .readyForTap:
            let type = readingEvent == .notReady ? "notReady" : "readyForTap"
            emitTransactionEvent(event, intentId: intentId, type: type)
          case .cardDetected, .removeCard:
            let type = readingEvent == .cardDetected ? "cardDetected" : "removeCard"
            emitTransactionEvent(event, intentId: intentId, type: type)
          case .readRetry:
            emitTransactionEvent(event, intentId: intentId, type: "readRetry")
          case .pinEntryRequested:
            emitTransactionEvent(event, intentId: intentId, type: "pinEntryRequested")
          case .readCancelled, .readNotCompleted, .userInterfaceDismissed:
            if readingEvent == .readCancelled {
              emitTransactionEvent(event, intentId: intentId, type: "readCancelled")
            } else if readingEvent == .readNotCompleted {
              emitTransactionEvent(event, intentId: intentId, type: "readNotCompleted")
            } else {
              emitTransactionEvent(event, intentId: intentId, type: "userInterfaceDismissed")
            }
          case .readCompleted, .pinEntryCompleted:
            let type = readingEvent == .readCompleted ? "readCompleted" : "pinEntryCompleted"
            emitTransactionEvent(event, intentId: intentId, type: type)
          @unknown default:
            break
          }
        case .relinking:
          emitTransactionEvent(
            event,
            intentId: intentId,
            type: "relinking",
            data: ["provider": "apple", "state": "relinking"]
          )
        case .readingCompleted:
          emitTransactionEvent(event, intentId: intentId, type: "readingCompleted")
        @unknown default:
          break
        }
      case .nearpay(let nearpayState):
        switch nearpayState {
        case .waiting:
          emitTransactionEvent(event, intentId: intentId, type: "waiting")
        case .reading:
          emitTransactionEvent(event, intentId: intentId, type: "reading")
        case .pinRequested(let pinEntryView):
          presentPinEntryView(pinEntryView)
          emitTransactionEvent(event, intentId: intentId, type: "pinRequested")
        case .readingCompleted:
          emitTransactionEvent(event, intentId: intentId, type: "readingCompleted")
        case .cancelled:
          emitTransactionEvent(event, intentId: intentId, type: "readCancelled")
        @unknown default:
          break
        }
      @unknown default:
        break
      }
    case .failure(let error):
      let message = errorMessage(from: error)
      let nativeDescription = String(describing: error)
      let reportedMessage = nativeDescription == message ? message : "\(message) [\(nativeDescription)]"
      emitTransactionEvent(
        event,
        intentId: intentId,
        type: "readingFailure",
        message: reportedMessage,
        data: ["nativeError": serializeNativeError(error, code: "READING_FAILURE", message: message)]
      )
    }
  }

  private func handleTransactionResult(
    _ result: TransactionRequestResult,
    event: Event,
    intentId: UUID,
    successType: String,
    failureType: String
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      switch result {
      case .success(let response):
        self.dismissPinEntryView()
        let payload = self.serializeTransactionResponse(response)
        self.emitTransactionEvent(event, intentId: intentId, type: successType, data: payload)
      case .failure(let error):
        self.dismissPinEntryView()
        let message = self.errorMessage(from: error)
        self.emitTransactionEvent(
          event,
          intentId: intentId,
          type: failureType,
          message: message,
          data: [
            "nativeError": self.serializeNativeError(
              error,
              code: failureType.uppercased(),
              message: message
            )
          ]
        )
      }
    }
  }

  private func wrapReconciliationReceipt(_ response: ReconciliationResponse?) -> [String: Any]? {
    ResponseSerializer.wrapReconciliationReceipt(response)
  }

  private func shouldFallbackReconciliationFetch(_ message: String) -> Bool {
    let normalized = message.lowercased()
    let mentionsCardAcceptorTerminalId = normalized.contains("card_acceptor_terminal_id")
      || normalized.contains("cardacceptorterminalid")
    let mentionsUUIDDecode = normalized.contains("uuid")
      || normalized.contains("decode")
      || normalized.contains("decoding")
    return mentionsCardAcceptorTerminalId && mentionsUUIDDecode
  }

  private func fetchReconciliationFallbackFromList(
    terminal: NearpayTerminal,
    reconciliationID: UUID,
    originalErrorMessage: String,
    wrapped: Bool,
    resolver resolve: @escaping FlutterResult
  ) {
    let pageSize = 100
    let maxPages = 20

    func fetchPage(_ pageNumber: Int) {
      let query = ReconciliationListQuery(
        pageNumber: pageNumber,
        pageSize: pageSize,
        startDate: nil,
        endDate: nil
      )

      terminal.getReconciliationList(query: query) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            if let matched = response.reconciliationList.first(where: { $0.id == reconciliationID }) {
              let payload: [String: Any]? = wrapped
                ? self.wrapReconciliationListItem(matched)
                : ResponseSerializer.reconciliationListItemPayload(matched)
              if let payload {
                resolve(self.responseHandlerSuccess(message: BridgeMessages.reconciliationFetchedSummaryFallback, data: payload))
                return
              }
            }

            let totalPages = response.pagination.totalPages ?? pageNumber
            if pageNumber < totalPages, pageNumber < maxPages {
              fetchPage(pageNumber + 1)
              return
            }

            resolve(self.responseHandlerError(code: "RECONCILIATION_FETCH_FAILURE", message: originalErrorMessage))

          case .failure:
            resolve(self.responseHandlerError(code: "RECONCILIATION_FETCH_FAILURE", message: originalErrorMessage))
          }
        }
      }
    }

    fetchPage(1)
  }

  private func wrapReconciliationListItem(_ item: ReconciliationItem) -> [String: Any]? {
    ResponseSerializer.wrapReconciliationListItem(item)
  }

  private func serializeTransactionResponse(_ response: TransactionResponse) -> [String: Any] {
    ResponseSerializer.serializeTransactionResponse(response)
  }

  private func serializeIntentDetails(_ details: TransactionResponse.IntentDetails) -> [String: Any] {
    ResponseSerializer.serializeIntentDetails(details)
  }

  private func serializeReconciliationReceipt(_ receipt: ReconciliationReceipt) -> [String: Any]? {
    ResponseSerializer.serializeReconciliationReceipt(receipt)
  }

  private func serializeTransactionListResponse(_ response: TransactionListResponse) -> [String: Any]? {
    ResponseSerializer.serializeTransactionListResponse(response)
  }

  private func serializeIntentListResponse(_ response: IntentListResponse) -> [String: Any] {
    ResponseSerializer.serializeIntentListResponse(response)
  }

  private func serializeInvoiceResponse(_ response: InvoiceResponse) -> [String: Any] {
    ResponseSerializer.serializeInvoiceResponse(response)
  }

  private func serializeInvoiceListResponse(_ response: InvoiceListResponse) -> [String: Any] {
    ResponseSerializer.serializeInvoiceListResponse(response)
  }

  private func serializeProductListResponse(_ response: ProductListResponse) -> [String: Any] {
    ResponseSerializer.serializeProductListResponse(response)
  }

  private func serializeProductDetails(_ product: ProductDetails) -> [String: Any] {
    ResponseSerializer.serializeProductDetails(product)
  }

  private func serializeInvoiceDetails(_ details: InvoiceDetails) -> [String: Any] {
    ResponseSerializer.serializeInvoiceDetails(details)
  }

  private func serializeReconciliationListResponse(_ response: ReconciliationListResponse) -> [String: Any]? {
    ResponseSerializer.serializeReconciliationListResponse(response)
  }

  private func serializeTerminalConfigResponse(_ response: TerminalConfigurationResponse) -> [String: Any]? {
    ResponseSerializer.serializeTerminalConfigResponse(response)
  }

  private func serializeTransactionQueryResponse(_ response: TransactionQueryResponse) -> [String: Any]? {
    ResponseSerializer.serializeTransactionQueryResponse(response)
  }

  private func statusMessageDictionary(from field: LocalizationField?) -> [String: String]? {
    guard let field else { return nil }
    let arabic = field.arabic
    let english = field.english
    if arabic.isEmpty && english.isEmpty { return nil }
    return [
      "arabic": arabic,
      "english": english,
      "ar": arabic,
      "en": english
    ]
  }

  private static func settledModuleReleasedResponse() -> [String: Any] {
    BridgeErrorMapper.settledModuleReleasedResponse()
  }

  private func responseHandlerSuccess(message: String, data: Any? = nil) -> [String: Any] {
    var payload: [String: Any] = [
      "status": "success",
      "message": message
    ]
    payload["data"] = data ?? [:]
    return payload
  }

  private func responseHandlerError(
    code: String,
    message: String,
    underlyingError: Error? = nil
  ) -> [String: Any] {
    BridgeErrorMapper.responseHandlerError(
      code: code,
      message: message,
      underlyingError: underlyingError
    )
  }

  private func bridgeNativeError(
    code: String,
    message: String,
    nativeType: String? = nil,
    details: [String: Any]? = nil
  ) -> [String: Any] {
    BridgeErrorMapper.bridgeNativeError(
      code: code,
      message: message,
      nativeType: nativeType,
      details: details
    )
  }

  private func serializeNativeError(
    _ error: Error,
    code: String? = nil,
    message: String? = nil,
    depth: Int = 0
  ) -> [String: Any] {
    BridgeErrorMapper.serializeNativeError(error, code: code, message: message, depth: depth)
  }

  private func errorMessage(from error: Error) -> String {
    BridgeErrorMapper.errorMessage(from: error)
  }

  private func presentPinEntryView(_ view: TerminalPINEntryView) {
    DispatchQueue.main.async {
      self.dismissPinEntryView()

      let hostingController = UIHostingController(rootView: view)
      hostingController.modalPresentationStyle = .overFullScreen
      hostingController.view.backgroundColor = .clear

      guard let presenter = self.flutterTopViewController() else {
        return
      }

      if presenter.presentedViewController != nil {
        presenter.dismiss(animated: false) {
          presenter.present(hostingController, animated: true)
          self.pinEntryHostingController = hostingController
        }
        return
      }

      presenter.present(hostingController, animated: true)
      self.pinEntryHostingController = hostingController
    }
  }

  private func dismissPinEntryView() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, let controller = self.pinEntryHostingController else { return }

      controller.dismiss(animated: true) {
        self.pinEntryHostingController = nil
      }

      if controller.presentingViewController == nil {
        self.pinEntryHostingController = nil
      }
    }
  }

  @discardableResult
  private func presentQrPaymentHost() -> Bool {
    if !Thread.isMainThread {
      DispatchQueue.main.async { _ = self.presentQrPaymentHost() }
      return false
    }

    if qrPaymentHostingController != nil {
      return true
    }

    let hostingController = UIHostingController(rootView: QrPaymentHostRoot())
    hostingController.modalPresentationStyle = .overFullScreen
    hostingController.view.backgroundColor = .clear
    hostingController.view.isOpaque = false
    hostingController.view.isUserInteractionEnabled = false

    guard let presenter = flutterTopViewController() else {
      return false
    }

    presenter.present(hostingController, animated: false)
    qrPaymentHostingController = hostingController
    return true
  }

  private func setQrPaymentHostInteractive(_ enabled: Bool) {
    if !Thread.isMainThread {
      DispatchQueue.main.async { self.setQrPaymentHostInteractive(enabled) }
      return
    }
    qrPaymentHostingController?.view.isUserInteractionEnabled = enabled
  }

  private func dismissQrPaymentHost() {
    if !Thread.isMainThread {
      DispatchQueue.main.async { self.dismissQrPaymentHost() }
      return
    }

    guard let controller = qrPaymentHostingController else { return }

    qrPaymentHostingController = nil
    if controller.presentingViewController != nil {
      controller.dismiss(animated: true)
    }
  }

  private func encodeToJSONObject<T: Encodable>(_ value: T) -> Any? {
    BridgeSerialization.encodeToJSONObject(value)
  }

  private func makeTransactionListQuery(from dictionary: [String: Any]?) -> TransactionListQuery? {
    RequestParser.makeTransactionListQuery(from: dictionary)
  }

  private func rejectedInvalidDate(
    in dictionary: [String: Any]?,
    resolve: @escaping FlutterResult
  ) -> Bool {
    guard let key = RequestParser.invalidDateKey(in: dictionary) else { return false }
    resolve(
      responseHandlerError(
        code: "INVALID_DATE",
        message: "\(key) must be an epoch timestamp or an ISO 8601 date"
      )
    )
    return true
  }

  private func makeReconciliationListQuery(from dictionary: [String: Any]?) -> ReconciliationListQuery? {
    RequestParser.makeReconciliationListQuery(from: dictionary)
  }

  private func paymentType(from value: String) -> TerminalSDK.PaymentType? {
    RequestParser.paymentType(from: value)
  }

  private func invoiceItems(from value: Any?) -> [InvoiceItem]? {
    RequestParser.invoiceItems(from: value)
  }

  private func uint64Value(from value: Any?) -> UInt64? {
    RequestParser.uint64Value(from: value)
  }

  private func validateWholeNumber(
    in dictionary: [String: Any],
    keys: [String],
    code: String,
    message: String,
    resolve: @escaping FlutterResult
  ) -> Bool {
    let supplied = keys.compactMap { dictionary[$0] }.first { !($0 is NSNull) }
    guard let supplied else { return true }
    guard uint64Value(from: supplied) == nil else { return true }
    resolve(responseHandlerError(code: code, message: message))
    return false
  }

  private func validateSurchargeAndTax(
    in dictionary: [String: Any],
    resolve: @escaping FlutterResult
  ) -> Bool {
    validateWholeNumber(
      in: dictionary,
      keys: ["surchargeAmount", "surcharge_amount"],
      code: "INVALID_SURCHARGE_AMOUNT",
      message: BridgeMessages.invalidSurchargeAmount,
      resolve: resolve
    ) && validateWholeNumber(
      in: dictionary,
      keys: ["taxPercentage", "tax_percentage"],
      code: "INVALID_TAX_PERCENTAGE",
      message: BridgeMessages.invalidTaxPercentage,
      resolve: resolve
    )
  }

  private func taxPercentageValue(in dictionary: [String: Any]) -> UInt64? {
    uint64Value(from: dictionary["taxPercentage"] ?? dictionary["tax_percentage"])
  }

  private func doubleValue(from value: Any?) -> Double? {
    RequestParser.doubleValue(from: value)
  }

  private func timeIntervalValue(from value: Any?) -> TimeInterval? {
    RequestParser.timeIntervalValue(from: value)
  }

  private func boolValue(from value: Any?) -> Bool? {
    RequestParser.boolValue(from: value)
  }

  private func uuidValue(from value: Any?) -> UUID? {
    RequestParser.uuidValue(from: value)
  }

  private func paymentCardScheme(from value: Any?) -> ReaderPaymentCardScheme? {
    RequestParser.paymentCardScheme(from: value)
  }

  private func stringValue(from value: Any?) -> String? {
    BridgeSerialization.stringValue(from: value)
  }

  private func rawStringValue(from value: Any?) -> String? {
    RequestParser.rawStringValue(from: value)
  }

  private func parseSDKConfiguration(from configuration: NSDictionary) -> SDKConfiguration {
    RequestParser.parseSDKConfiguration(from: configuration)
  }

  private func makeTerminalListQuery(from dictionary: [String: Any]?) -> TerminalListQuery? {
    RequestParser.makeTerminalListQuery(from: dictionary)
  }

  private func makeListQuery(from dictionary: [String: Any]?) -> ListQuery? {
    RequestParser.makeListQuery(from: dictionary)
  }

  private func handleLogout(userId: UserID) {
    if currentUser?.id == userId {
      currentUser = nil
      currentTerminal = nil
      currentAuthentication = nil
    }

    emitFlutterMethod(
      "NearpayTerminalOnLogout",
      arguments: ["userUUID": "\(userId)"]
    )
  }

  private func handleTerminalDisconnect(terminalId: TerminalID) {
    if currentTerminal?.id == terminalId {
      currentTerminal = nil
    }

    emitFlutterMethod(
      "NearpayTerminalOnDisconnect",
      arguments: ["terminalUUID": "\(terminalId)"]
    )

  }

  private func dictionary(from params: NSDictionary?) -> [String: Any]? {
    RequestParser.dictionary(from: params)
  }

  private func intValue(from value: Any?) -> Int? {
    RequestParser.intValue(from: value)
  }

  private func serializeAuthenticationObjects(_ objects: AuthenticationObjects) -> [String: Any] {
    ResponseSerializer.serializeAuthenticationObjects(objects)
  }

  private func serializeUser(_ user: NearpayUser) -> [String: Any] {
    ResponseSerializer.serializeUser(user)
  }

  private func serializeTerminal(_ terminal: NearpayTerminal, tid: String? = nil, name: String? = nil) -> [String: Any] {
    ResponseSerializer.serializeTerminal(terminal, tid: tid, name: name)
  }

  private func serializeTerminalListResponse(
    _ response: TerminalListResponse,
    userUUID: String
  ) -> [String: Any] {
    ResponseSerializer.serializeTerminalListResponse(response, userUUID: userUUID)
  }

  private func serializeLocalizationField(_ field: LocalizationField) -> [String: Any] {
    ResponseSerializer.serializeLocalizationField(field)
  }

  private func ensureKeychainResetIfNeeded() {
    let defaults = UserDefaults.standard
    guard !defaults.bool(forKey: Self.installationFlagKey) else { return }

    Self.clearKeychain(service: Bundle.main.bundleIdentifier ?? "")
    defaults.set(true, forKey: Self.installationFlagKey)
  }

  private static func clearKeychain(service: String) {
    guard !service.isEmpty else { return }

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service
    ]

    let status = SecItemDelete(query as CFDictionary)
    _ = status
  }

  private func rejectPromise(_ reject: FlutterResult, error: Error) {
    if let bridgeError = error as? BridgeError {
      reject(responseHandlerError(code: bridgeError.code, message: bridgeError.errorDescription ?? bridgeError.code))
      return
    }
    if let messageError = BridgeErrorMapper.messageError(from: error) {
      reject(
        responseHandlerError(
          code: messageError.codeText.uppercased(),
          message: BridgeErrorMapper.errorMessage(from: error),
          underlyingError: error
        )
      )
      return
    }
    if let localizedError = error as? LocalizedError,
       let message = localizedError.errorDescription {
      reject(responseHandlerError(code: "E_NEARPAY_SDK", message: message, underlyingError: error))
      return
    }
    let message = String(describing: error)
    reject(responseHandlerError(code: "E_NEARPAY_SDK", message: message, underlyingError: error))
  }

}

private extension String {
  var nilIfEmpty: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

extension NearpayFlutterBridge {
  private func sendMobileOtp(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      guard let interface = self.terminalInterface else {
        resolve(self.responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
        return
      }

      guard let mobileNumber = self.stringValue(from: params["mobileNumber"]) else {
        resolve(self.responseHandlerError(code: "MISSING_MOBILE", message: BridgeMessages.missingMobile))
        return
      }

      let authentication = interface.authenticator(with: .mobile(mobileNumber))
      self.currentAuthentication = authentication

      authentication.sendOTP { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            resolve(self.responseHandlerSuccess(message: BridgeMessages.otpSent))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "OTP_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  private func sendEmailOtp(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      guard let interface = self.terminalInterface else {
        resolve(self.responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
        return
      }

      guard let email = self.stringValue(from: params["email"]) else {
        resolve(self.responseHandlerError(code: "MISSING_EMAIL", message: BridgeMessages.missingEmail))
        return
      }

      let authentication = interface.authenticator(with: .email(email))
      self.currentAuthentication = authentication

      authentication.sendOTP { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            resolve(self.responseHandlerSuccess(message: BridgeMessages.otpSent))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "OTP_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  private func jwtVerify(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return
    }

    guard let jwt = stringValue(from: params["jwt"]) else {
      resolve(responseHandlerError(code: "MISSING_JWT", message: BridgeMessages.missingJWT))
      return
    }

    DispatchQueue.main.async {
      interface.login(with: .jwt(jwt)) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let objects):
            self.currentAuthentication = objects.authenticator
            if let user = objects.user {
              self.currentUser = user
            }
            guard let terminal = objects.terminal else {
              resolve(self.responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noTerminalReturned))
              return
            }
            self.currentTerminal = terminal
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.loginSuccessful,
                data: self.serializeTerminal(terminal, tid: terminal.tid, name: terminal.name)
              )
            )
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "VERIFY_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  private func verifyMobileOtp(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      guard let interface = self.terminalInterface else {
        resolve(self.responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
        return
      }

      guard let mobileNumber = self.stringValue(from: params["mobileNumber"]) else {
        resolve(self.responseHandlerError(code: "MISSING_MOBILE", message: BridgeMessages.missingMobile))
        return
      }

      guard let code = self.stringValue(from: params["code"]) else {
        resolve(self.responseHandlerError(code: "MISSING_CODE", message: BridgeMessages.missingOTPCode))
        return
      }

      let authentication = interface.authenticator(with: .mobile(mobileNumber))
      self.currentAuthentication = authentication

      authentication.verify(otp: code) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let user):
            self.currentUser = user
            let payload = self.serializeUser(user)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.loginSuccessful(name: user.info.name), data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "VERIFY_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  private func verifyEmailOtp(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      guard let interface = self.terminalInterface else {
        resolve(self.responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
        return
      }

      guard let email = self.stringValue(from: params["email"]) else {
        resolve(self.responseHandlerError(code: "MISSING_EMAIL", message: BridgeMessages.missingEmail))
        return
      }

      guard let code = self.stringValue(from: params["code"]) else {
        resolve(self.responseHandlerError(code: "MISSING_CODE", message: BridgeMessages.missingOTPCode))
        return
      }

      let authentication = interface.authenticator(with: .email(email))
      self.currentAuthentication = authentication

      authentication.verify(otp: code) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let user):
            self.currentUser = user
            let payload = self.serializeUser(user)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.loginSuccessful(name: user.info.name), data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "VERIFY_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getUser(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return
    }

    guard let userIdString = stringValue(from: params["uuid"] ?? params["userUUID"] ?? params["userId"]) else {
      resolve(responseHandlerError(code: "MISSING_UUID", message: BridgeMessages.missingUserUUID))
      return
    }

    guard let userId = UUID(uuidString: userIdString) else {
      resolve(responseHandlerError(code: "INVALID_UUID", message: BridgeMessages.invalidUUID(userIdString)))
      return
    }

    if let current = currentUser, current.id == userId {
      resolve(responseHandlerSuccess(message: BridgeMessages.userFetched, data: serializeUser(current)))
      return
    }

    if let fetched = interface.user(with: userId) {
      self.currentUser = fetched
      resolve(responseHandlerSuccess(message: BridgeMessages.userFetched, data: serializeUser(fetched)))
      return
    }

    resolve(responseHandlerError(code: "USER_NOT_FOUND", message: BridgeMessages.userNotFound))
  }

  func getTerminal(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return
    }

    guard let terminalIdString = stringValue(from: params["terminalUUID"] ?? params["terminalId"] ?? params["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_UUID", message: BridgeMessages.missingTerminalUUID))
      return
    }

    guard let terminalId = UUID(uuidString: terminalIdString) else {
      resolve(responseHandlerError(code: "INVALID_UUID", message: BridgeMessages.invalidUUID(terminalIdString)))
      return
    }

    let linkingHandler: TerminalLinkingRequestHandler = { [weak self] result in
      guard let self else { return }
      DispatchQueue.main.async {
        self.handleLinkingResult(result) { type, message, data in
          self.emitTerminalLinkingEvent(
            operation: .getTerminal,
            terminalId: terminalId,
            type: type,
            message: message,
            data: data
          )
        }
      }
    }

    if let current = currentTerminal, current.id == terminalId {
      resolve(responseHandlerSuccess(message: BridgeMessages.terminalFetched, data: serializeTerminal(current)))
      return
    }

    if let fetched = interface.terminal(with: terminalId, readerLinkingHandler: linkingHandler) {
      self.currentTerminal = fetched
      resolve(responseHandlerSuccess(message: BridgeMessages.terminalFetched, data: serializeTerminal(fetched)))
      return
    }

    emitTerminalLinkingEvent(
      operation: .getTerminal,
      terminalId: terminalId,
      type: "linkingFailure",
      message: BridgeMessages.terminalNotFound,
      data: [
        "nativeError": bridgeNativeError(
          code: "TERMINAL_NOT_FOUND",
          message: BridgeMessages.terminalNotFound
        )
      ]
    )
    resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.terminalNotFound))
  }

  func authenticator(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    DispatchQueue.main.async {
      guard let interface = self.terminalInterface else {
        resolve(self.responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
        return
      }

      let dictionary = params as? [String: Any] ?? [:]
      let explicitType = self.stringValue(from: dictionary["type"])?.lowercased()
      let explicitValue = self.stringValue(from: dictionary["value"])

      let method: TerminalAuthenticationMethod
      let type: String
      let value: String

      if let explicitType {
        guard let explicitValue, !explicitValue.isEmpty else {
          resolve(self.responseHandlerError(code: "MISSING_VALUE", message: BridgeMessages.missingValueWhenType))
          return
        }

        switch explicitType {
        case "mobile":
          method = .mobile(explicitValue)
          type = "mobile"
          value = explicitValue
        case "email":
          method = .email(explicitValue)
          type = "email"
          value = explicitValue
        default:
          resolve(self.responseHandlerError(code: "INVALID_TYPE", message: BridgeMessages.invalidAuthType))
          return
        }
      } else if let mobile = self.stringValue(from: dictionary["mobileNumber"] ?? dictionary["mobile"]) {
        method = .mobile(mobile)
        type = "mobile"
        value = mobile
      } else if let email = self.stringValue(from: dictionary["email"]) {
        method = .email(email)
        type = "email"
        value = email
      } else {
        resolve(self.responseHandlerError(code: "MISSING_AUTH_METHOD", message: BridgeMessages.missingAuthMethod))
        return
      }

      self.currentAuthentication = interface.authenticator(with: method)
      resolve(
        self.responseHandlerSuccess(
          message: BridgeMessages.authenticatorInitialized,
          data: [
            "requiresOtp": true,
            "type": type,
            "value": value
          ]
        )
      )
    }
  }

  func getTerminalList(
    _ queryParams: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return
    }

    let queryDictionary = dictionary(from: queryParams) ?? [:]
    let query = makeTerminalListQuery(from: queryDictionary)

    let userIdString = stringValue(from: queryDictionary["uuid"]
      ?? queryDictionary["userUUID"]
      ?? queryDictionary["userId"])
    let userId = userIdString.flatMap { UUID(uuidString: $0) }
    let user = currentUser
      ?? (userId.flatMap { interface.user(with: $0) })

    guard let user else {
      resolve(responseHandlerError(code: "USER_NOT_FOUND", message: BridgeMessages.noAuthenticatedUser))
      return
    }

    DispatchQueue.main.async {
      user.getTerminalList(query: query) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeTerminalListResponse(
              response,
              userUUID: user.id.uuidString
            )
            resolve(self.responseHandlerSuccess(message: BridgeMessages.terminalListFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_TERMINAL_LIST_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func connectTerminal(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    let terminalIdString = stringValue(from: dictionary["terminalId"]
      ?? dictionary["terminalUUID"]
      ?? dictionary["uuid"])

    guard let terminalIdString, let terminalId = UUID(uuidString: terminalIdString) else {
      resolve(responseHandlerError(code: "INVALID_UUID", message: BridgeMessages.missingTerminalId))
      return
    }

    let userIdString = stringValue(from: dictionary["userUUID"] ?? dictionary["userId"])
    let userId = userIdString.flatMap { UUID(uuidString: $0) }
    let user = currentUser
      ?? (userId.flatMap { interface.user(with: $0) })

    guard let user else {
      resolve(responseHandlerError(code: "USER_NOT_FOUND", message: BridgeMessages.noAuthenticatedUser))
      return
    }

    let linkingHandler: TerminalLinkingRequestHandler = { [weak self] result in
      guard let self else { return }
      DispatchQueue.main.async {
        self.handleLinkingResult(result) { type, message, data in
          self.emitTerminalLinkingEvent(
            operation: .connectTerminal,
            terminalId: terminalId,
            type: type,
            message: message,
            data: data
          )
        }
      }
    }

    DispatchQueue.main.async {
      user.connectToTerminal(with: terminalId, readerLinkingHandler: linkingHandler) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let terminal):
            self.currentTerminal = terminal
            let requestTid = self.stringValue(from: dictionary["tid"])
            let requestName = self.stringValue(from: dictionary["name"])
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.terminalConnected,
                data: self.serializeTerminal(terminal, tid: requestTid, name: requestName)
              )
            )
          case .failure(let error):
            let message = self.errorMessage(from: error)
            self.emitTerminalLinkingEvent(
              operation: .connectTerminal,
              terminalId: terminalId,
              type: "linkingFailure",
              message: message,
              data: [
                "nativeError": self.serializeNativeError(
                  error,
                  code: "CONNECT_FAILURE",
                  message: message
                )
              ]
            )
            resolve(
              self.responseHandlerError(
                code: "CONNECT_FAILURE",
                message: message,
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func disconnectTerminal(
    _ resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      rejectPromise(reject, error: TerminalError.invalidRequest(.terminalDisconnected))
      return
    }

    DispatchQueue.main.async {
      terminal.disconnect { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            self.currentTerminal = nil
            resolve(true)
          case .failure(let error):
            self.rejectPromise(reject, error: error)
          }
        }
      }
    }
  }

  func logout(
    _ resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let user = currentUser else {
      rejectPromise(reject, error: TerminalError.invalidRequest(.userNotFound))
      return
    }

    DispatchQueue.main.async {
      user.logout { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            self.currentUser = nil
            self.currentTerminal = nil
            self.currentAuthentication = nil
            resolve(true)
          case .failure(let error):
            self.rejectPromise(reject, error: error)
          }
        }
      }
    }
  }
}

extension NearpayFlutterBridge {
  func routingLookup(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])
    let latitude = doubleValue(from: dictionary["lat"] ?? dictionary["latitude"])
    let longitude = doubleValue(from: dictionary["long"] ?? dictionary["longitude"])
    let isLocationFromMock = boolValue(from: dictionary["isLocationFromMock"]
      ?? dictionary["is_location_from_mock"])

    DispatchQueue.main.async { [weak self] in
      guard let self else {
        resolve(Self.settledModuleReleasedResponse())
        return
      }

      let linkingHandler: TerminalLinkingRequestHandler = { [weak self] result in
        guard let self else { return }
        self.handleLinkingResult(result) { type, message, data in
          self.emitTransactionEvent(
            .routingLookupEvent,
            intentId: intentId,
            type: type,
            message: message,
            data: data
          )
        }
      }
      let readingHandler: TerminalSDK.ReadingHandler = { [weak self] result in
        DispatchQueue.main.async {
          self?.handleReadingResult(result, event: .routingLookupEvent, intentId: intentId)
        }
      }

      terminal.routingLookup(
        id: intentId,
        amount: amount,
        scheme: scheme,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        isLocationFromMock: isLocationFromMock,
        linkingHandler: linkingHandler,
        readingHandler: readingHandler
      ) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else { return }
          self.dismissPinEntryView()
          switch result {
          case .success(let success):
            self.routingSessions[Self.routingSessionKey(intentId.uuidString)] = success.session
            self.emitTransactionEvent(
              .routingLookupEvent,
              intentId: intentId,
              type: "routingLookupCompleted",
              data: self.serializeRoutingLookup(success, sessionId: intentId)
            )
          case .failure(let error):
            let message = self.errorMessage(from: error)
            self.emitTransactionEvent(
              .routingLookupEvent,
              intentId: intentId,
              type: "routingLookupFailure",
              message: message,
              data: [
                "nativeError": self.serializeNativeError(
                  error,
                  code: "ROUTING_LOOKUP_FAILURE",
                  message: message
                )
              ]
            )
          }
        }
      }

      resolve(self.responseHandlerSuccess(message: BridgeMessages.routingLookupStarted))
    }
  }

  func routingExecute(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let request = requireRoutingRequest(from: dictionary, resolver: resolve) else { return }

    let numberOfInstallments = intValue(from: dictionary["numberOfInstallments"]
      ?? dictionary["number_of_installments"])

    runRoutingTransaction(
      sessionKey: request.sessionKey,
      intentId: request.session.intentId,
      failureCode: "ROUTING_EXECUTE_FAILURE",
      resolver: resolve
    ) { readingHandler, completion in
      terminal.routingExecute(
        session: request.session,
        selectedAcquirerTerminalId: request.selectedAcquirerTerminalId,
        customerReferenceNumber: request.customerReferenceNumber,
        numberOfInstallments: numberOfInstallments,
        readingHandler: readingHandler,
        handler: completion
      )
    }
  }

  func routingInstallments(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let request = requireRoutingRequest(from: dictionary, resolver: resolve) else { return }

    guard let installmentOptions = parseInstallmentOptions(from: dictionary) else {
      resolve(
        responseHandlerError(
          code: "INVALID_INSTALLMENT_OPTIONS",
          message: BridgeMessages.invalidInstallmentOptions
        )
      )
      return
    }

    guard !installmentOptions.isEmpty else {
      resolve(
        responseHandlerError(
          code: "MISSING_INSTALLMENT_OPTIONS",
          message: BridgeMessages.missingInstallmentOptions
        )
      )
      return
    }

    runRoutingTransaction(
      sessionKey: request.sessionKey,
      intentId: request.session.intentId,
      failureCode: "ROUTING_INSTALLMENTS_FAILURE",
      resolver: resolve
    ) { readingHandler, completion in
      terminal.routingInstallments(
        session: request.session,
        selectedAcquirerTerminalId: request.selectedAcquirerTerminalId,
        installmentOptions: installmentOptions,
        customerReferenceNumber: request.customerReferenceNumber,
        readingHandler: readingHandler,
        handler: completion
      )
    }
  }

  func getRoutingProfile(
    _ resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    DispatchQueue.main.async {
      terminal.getRoutingProfile { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let profile):
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.routingProfileLoaded,
                data: self.serializeRoutingProfile(profile)
              )
            )
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_ROUTING_PROFILE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func batchCapture(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let terminal = requireTerminal(forUUIDIn: dictionary, resolver: resolve) else {
      return
    }

    DispatchQueue.main.async {
      terminal.batchCapture { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.batchCaptureCompleted,
                data: ["value": response.value]
              )
            )
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "BATCH_CAPTURE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func isOperationSupported(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let requested = stringValue(from: dictionary["operation"]
      ?? dictionary["operationName"]), !requested.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_OPERATION", message: BridgeMessages.missingOperationName))
      return
    }

    guard let operation = Self.terminalOperation(named: requested) else {
      resolve(
        responseHandlerError(
          code: "UNKNOWN_OPERATION",
          message: BridgeMessages.unknownOperation(requested)
        )
      )
      return
    }

    guard let terminal = requireTerminal(forUUIDIn: dictionary, resolver: resolve) else {
      return
    }

    let supported = terminal.isOperationSupported(operation)

    resolve(
      responseHandlerSuccess(
        message: BridgeMessages.operationSupportResolved,
        data: [
          "operation": requested,
          "supported": supported
        ]
      )
    )
  }

  private func requireTerminal(
    forUUIDIn dictionary: [String: Any],
    resolver resolve: @escaping FlutterResult
  ) -> NearpayTerminal? {
    guard let interface = terminalInterface else {
      resolve(responseHandlerError(code: "NOT_INITIALIZED", message: BridgeMessages.notInitialized))
      return nil
    }

    guard let terminalIdString = stringValue(
      from: dictionary["terminalUUID"] ?? dictionary["terminalId"] ?? dictionary["uuid"]
    ), !terminalIdString.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_UUID", message: BridgeMessages.missingTerminalUUID))
      return nil
    }

    guard let terminalId = UUID(uuidString: terminalIdString) else {
      resolve(responseHandlerError(code: "INVALID_UUID", message: BridgeMessages.invalidUUID(terminalIdString)))
      return nil
    }

    if let current = currentTerminal, current.id == terminalId {
      return current
    }

    if let fetched = interface.terminal(with: terminalId, readerLinkingHandler: nil) {
      currentTerminal = fetched
      return fetched
    }

    resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.terminalNotFound))
    return nil
  }

  static func routingSessionKey(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
  }

  static func terminalOperation(named value: String) -> TerminalSDK.TerminalOperation? {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if let match = TerminalSDK.TerminalOperation.allCases.first(
      where: { $0.rawValue.caseInsensitiveCompare(normalized) == .orderedSame }
    ) {
      return match
    }
    let aliases: [String: String] = [
      "increment": "incrementAuthorization",
      "capture": "captureAuthorization",
      "tip": "tipTransaction",
      "void": "voidAuthorization",
      "reverse": "reverseTransaction",
    ]
    guard let aliased = aliases[normalized.lowercased()] else {
      return nil
    }
    return TerminalSDK.TerminalOperation.allCases.first {
      $0.rawValue.caseInsensitiveCompare(aliased) == .orderedSame
    }
  }

  struct RoutingRequest {
    let sessionKey: String
    let session: TerminalSDK.RoutingSession
    let selectedAcquirerTerminalId: String
    let customerReferenceNumber: String?
  }

  private func requireRoutingRequest(
    from dictionary: [String: Any],
    resolver resolve: @escaping FlutterResult
  ) -> RoutingRequest? {
    guard let sessionId = stringValue(from: dictionary["sessionId"] ?? dictionary["session_id"]),
          !sessionId.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_SESSION_ID", message: BridgeMessages.missingSessionId))
      return nil
    }

    guard let selectedAcquirerTerminalId = stringValue(from: dictionary["selectedAcquirerTerminalId"]
      ?? dictionary["selected_acquirer_terminal_id"]), !selectedAcquirerTerminalId.isEmpty else {
      resolve(
        responseHandlerError(
          code: "MISSING_SELECTED_ACQUIRER_TERMINAL_ID",
          message: BridgeMessages.missingSelectedAcquirerTerminalId
        )
      )
      return nil
    }

    let key = Self.routingSessionKey(sessionId)
    guard let session = routingSessions[key] else {
      resolve(
        responseHandlerError(
          code: "ROUTING_SESSION_NOT_FOUND",
          message: BridgeMessages.routingSessionNotFound
        )
      )
      return nil
    }

    if session.isExpired() {
      routingSessions.removeValue(forKey: key)
      resolve(
        responseHandlerError(
          code: "ROUTING_SESSION_EXPIRED",
          message: BridgeMessages.routingSessionExpired
        )
      )
      return nil
    }

    return RoutingRequest(
      sessionKey: key,
      session: session,
      selectedAcquirerTerminalId: selectedAcquirerTerminalId,
      customerReferenceNumber: customerReference(from: dictionary)
    )
  }

  private func runRoutingTransaction(
    sessionKey: String,
    intentId: UUID,
    failureCode: String,
    resolver resolve: @escaping FlutterResult,
    start: @escaping (
      _ readingHandler: @escaping TerminalSDK.ReadingHandler,
      _ completion: @escaping TransactionRequestHandler
    ) -> Void
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        resolve(Self.settledModuleReleasedResponse())
        return
      }

      let readingHandler: TerminalSDK.ReadingHandler = { [weak self] result in
        DispatchQueue.main.async {
          self?.handleReadingResult(result, event: .routingLookupEvent, intentId: intentId)
        }
      }

      start(readingHandler) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          self.dismissPinEntryView()
          self.routingSessions.removeValue(forKey: sessionKey)
          switch result {
          case .success(let response):
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.transactionStarted,
                data: self.serializeTransactionResponse(response)
              )
            )
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: failureCode,
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  private func parseInstallmentOptions(
    from dictionary: [String: Any]
  ) -> [TerminalSDK.InstallmentOption]? {
    let rawEntries: [[String: Any]]

    if let json = stringValue(from: dictionary["installmentOptionsJson"]
      ?? dictionary["installment_options_json"]) {
      guard let data = json.data(using: .utf8),
            let decoded = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
        return nil
      }
      rawEntries = decoded
    } else if let list = dictionary["installmentOptions"] as? [[String: Any]] {
      rawEntries = list
    } else if let list = dictionary["installment_options"] as? [[String: Any]] {
      rawEntries = list
    } else {
      return nil
    }

    var options: [TerminalSDK.InstallmentOption] = []
    for entry in rawEntries {
      guard let count = intValue(from: entry["installmentCount"] ?? entry["installment_count"]),
            let percentage = doubleValue(from: entry["installmentPercentage"]
              ?? entry["installment_percentage"]),
            let plan = stringValue(from: entry["paymentPlan"] ?? entry["payment_plan"]),
            let total = doubleValue(from: entry["totalCalculatedAmount"]
              ?? entry["total_calculated_amount"]) else {
        return nil
      }
      options.append(
        TerminalSDK.InstallmentOption(
          installmentCount: count,
          installmentPercentage: percentage,
          paymentPlan: plan,
          totalCalculatedAmount: total
        )
      )
    }
    return options
  }

  private func serializeRoutingLookup(
    _ success: TerminalSDK.RoutingLookupSuccess,
    sessionId: UUID
  ) -> [String: Any] {
    let bin = success.response.binInformation
    var binPayload: [String: Any] = [:]
    binPayload["bin"] = bin?.bin ?? NSNull()
    binPayload["issuerId"] = bin?.issuerId ?? NSNull()
    binPayload["brand"] = bin?.brand ?? NSNull()
    binPayload["cardType"] = bin?.cardType ?? NSNull()

    return [
      "response": ["binInformation": binPayload],
      "sessionId": sessionId.uuidString
    ]
  }

  private func serializeRoutingProfile(_ profile: TerminalSDK.RoutingProfile) -> [String: Any] {
    [
      "serialNumber": profile.serialNumber,
      "terminals": profile.terminals.map { terminal -> [String: Any] in
        [
          "terminalInfo": [
            "bankName": terminal.terminalInfo.bankName ?? NSNull(),
            "acquirerId": terminal.terminalInfo.acquirerId ?? NSNull(),
            "acquirerTerminalId": terminal.terminalInfo.acquirerTerminalId,
            "virtualSerialNumber": terminal.terminalInfo.virtualSerialNumber ?? NSNull()
          ] as [String: Any],
          "merchantData": [
            "businessName": terminal.merchantData.businessName ?? NSNull(),
            "taxOfficeName": terminal.merchantData.taxOfficeName ?? NSNull(),
            "businessAddress": terminal.merchantData.businessAddress ?? NSNull(),
            "businessProvince": terminal.merchantData.businessProvince ?? NSNull(),
            "businessTelephone": terminal.merchantData.businessTelephone ?? NSNull(),
            "acquirerBusinessNo": terminal.merchantData.acquirerBusinessNo ?? NSNull(),
            "taxIdentificationNo": terminal.merchantData.taxIdentificationNo ?? NSNull(),
            "merchantCategoryCode": terminal.merchantData.merchantCategoryCode ?? NSNull()
          ] as [String: Any]
        ]
      }
    ]
  }
}

extension NearpayFlutterBridge {
  func purchase(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let terminal = requireTerminal(forUUIDIn: dictionary, resolver: resolve) else {
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    guard validateSurchargeAndTax(in: dictionary, resolve: resolve) else { return }

    let surchargeAmount = uint64Value(from: dictionary["surchargeAmount"] ?? dictionary["surcharge_amount"])
    let taxPercentage = taxPercentageValue(in: dictionary)
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])
    let withTokenization = boolValue(from: dictionary["withTokenization"]
      ?? dictionary["with_tokenization"]) ?? false
    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: intentId,
      event: .purchaseEvent,
      successType: "onSendTransactionCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.purchase(
          id: intentId,
          amount: amount,
          otherAmount: nil,
          surchargeAmount: surchargeAmount,
          taxPercentage: taxPercentage,
          scheme: scheme,
          timestamp: timestamp,
          customerReferenceNumber: customerReferenceNumber,
          withTokenization: withTokenization,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func purchaseWithTokenization(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let terminal = requireTerminal(forUUIDIn: dictionary, resolver: resolve) else {
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    guard let tokenizationID = stringValue(from: dictionary["tokenizationID"]
      ?? dictionary["tokenizationId"]
      ?? dictionary["tokenization_id"]), !tokenizationID.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_TOKENIZATION_ID", message: BridgeMessages.missingTokenizationID))
      return
    }

    guard validateSurchargeAndTax(in: dictionary, resolve: resolve) else { return }

    let surchargeAmount = uint64Value(from: dictionary["surchargeAmount"] ?? dictionary["surcharge_amount"])
    let taxPercentage = taxPercentageValue(in: dictionary)
    let customerReferenceNumber = stringValue(from: dictionary["customerReferenceNumber"]
      ?? dictionary["customer_reference_number"])

    DispatchQueue.main.async { [weak self] in
      guard let self else {
        resolve(Self.settledModuleReleasedResponse())
        return
      }
      terminal.purchaseWithTokenization(
        id: intentId,
        tokenizationID: tokenizationID,
        amount: amount,
        customerReferenceNumber: customerReferenceNumber,
        surchargeAmount: surchargeAmount,
        taxPercentage: taxPercentage
      ) { [weak self] result in
        self?.handleTransactionResult(
          result,
          event: .purchaseEvent,
          intentId: intentId,
          successType: "onSendTransactionCompleted",
          failureType: "sendTransactionFailure"
        )
      }
      resolve(self.responseHandlerSuccess(message: BridgeMessages.transactionStarted))
    }
  }

  func purchaseWithTip(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let terminal = requireTerminal(forUUIDIn: dictionary, resolver: resolve) else {
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    guard let otherAmount = uint64Value(from: dictionary["amountOther"] ?? dictionary["otherAmount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT_OTHER", message: BridgeMessages.missingTipAmount))
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    guard validateSurchargeAndTax(in: dictionary, resolve: resolve) else { return }

    let surchargeAmount = uint64Value(from: dictionary["surchargeAmount"] ?? dictionary["surcharge_amount"])
    let taxPercentage = taxPercentageValue(in: dictionary)
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])

    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: intentId,
      event: .purchaseWithTipEvent,
      successType: "onSendTransactionCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.purchaseWithTip(
          id: intentId,
          amount: amount,
          amountOther: otherAmount,
          surchargeAmount: surchargeAmount,
          taxPercentage: taxPercentage,
          scheme: scheme,
          timestamp: timestamp,
          customerReferenceNumber: customerReferenceNumber,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func refund(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    guard let originalIntentId = uuidValue(from: dictionary["refundUUID"]
      ?? dictionary["refundUuid"]
      ?? dictionary["refund_uuid"]
      ?? dictionary["originalIntentId"]
      ?? dictionary["originalIntentID"]
      ?? dictionary["original_intent_id"]
      ?? dictionary["originalJobId"]) else {
      resolve(responseHandlerError(code: "MISSING_REFUND_UUID", message: BridgeMessages.missingRefundUUID))
      return
    }

    let refundRRN = stringValue(from: dictionary["refundRRN"] ?? dictionary["refundRrn"])
    let scheme = paymentCardScheme(from: dictionary["scheme"])
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])

    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: intentId,
      event: .refundEvent,
      successType: "onSendTransactionCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.refund(
          id: intentId,
          originalIntentID: originalIntentId,
          refundRRN: refundRRN,
          amount: amount,
          scheme: scheme,
          timestamp: timestamp,
          customerReferenceNumber: customerReferenceNumber,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func openRefund(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])

    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: intentId,
      event: .refundEvent,
      successType: "onSendTransactionCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.openRefund(
          id: intentId,
          amount: amount,
          scheme: scheme,
          timestamp: timestamp,
          customerReferenceNumber: customerReferenceNumber,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func authorize(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUuidParam))
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    guard validateSurchargeAndTax(in: dictionary, resolve: resolve) else { return }

    let surchargeAmount = uint64Value(from: dictionary["surchargeAmount"] ?? dictionary["surcharge_amount"])
    let taxPercentage = taxPercentageValue(in: dictionary)
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])

    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: intentId,
      event: .authEvent,
      successType: "authorizeSuccess",
      failureType: "authorizeFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.authorize(
          id: intentId,
          amount: amount,
          surchargeAmount: surchargeAmount,
          taxPercentage: taxPercentage,
          scheme: scheme,
          timestamp: timestamp,
          customerReferenceNumber: customerReferenceNumber,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func refundWithoutTap(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let originalIntentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    guard let refundId = uuidValue(from: dictionary["refundUUID"]
      ?? dictionary["refundUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_REFUND_UUID", message: BridgeMessages.missingRefundUUID))
      return
    }

    let amount = uint64Value(from: dictionary["amount"])
    let customerReferenceNumber = stringValue(from: dictionary["customerReferenceNumber"]
      ?? dictionary["customer_reference_number"])

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      terminal.refundWithoutTap(
        id: refundId,
        originalIntentID: originalIntentId,
        amount: amount,
        customerReferenceNumber: customerReferenceNumber
      ) { [weak self] result in
        self?.handleTransactionResult(
          result,
          event: .refundEvent,
          intentId: refundId,
          successType: "onSendTransactionCompleted",
          failureType: "sendTransactionFailure"
        )
      }
      resolve(self.responseHandlerSuccess(message: BridgeMessages.transactionStarted))
    }
  }

  func captureAuthorizationWithTap(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    guard let authorizationId = uuidValue(from: dictionary["authorizationUUID"]
      ?? dictionary["authorizationUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_AUTHORIZATION_UUID", message: BridgeMessages.missingAuthorizationUUID))
      return
    }

    startTransaction(
      intentId: intentId,
      event: .captureAuthorizationWithTapEvent,
      successType: "captureWithTapCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.captureAuthorizationWithTap(
          id: intentId,
          originalIntentID: authorizationId,
          amount: amount,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func voidAuthorizationWithTap(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    guard let authorizationId = uuidValue(from: dictionary["authorizationUUID"]
      ?? dictionary["authorizationUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_AUTHORIZATION_UUID", message: BridgeMessages.missingAuthorizationUUID))
      return
    }

    let customerReferenceNumber = stringValue(from: dictionary["customerReferenceNumber"])

    startTransaction(
      intentId: authorizationId,
      event: .voidAuthorizationWithTapEvent,
      successType: "voidWithTapCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.voidAuthorizationWithTap(
          id: intentId,
          originalIntentID: authorizationId,
          amount: amount,
          customerReferenceNumber: customerReferenceNumber,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func customerReference(from dictionary: [String: Any]) -> String? {
    stringValue(from: dictionary["customerReferenceNumber"]
      ?? dictionary["customer_reference_number"])
  }

  func installments(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    guard let numberOfInstallments = intValue(from: dictionary["numberOfInstallments"]
      ?? dictionary["number_of_installments"]), numberOfInstallments > 0 else {
      resolve(
        responseHandlerError(
          code: "MISSING_NUMBER_OF_INSTALLMENTS",
          message: BridgeMessages.missingNumberOfInstallments
        )
      )
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])
    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: intentId,
      event: .installmentsEvent,
      successType: "onSendTransactionCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        terminal.installments(
          id: intentId,
          amount: amount,
          numberOfInstallments: numberOfInstallments,
          customerReferenceNumber: customerReferenceNumber,
          scheme: scheme,
          timestamp: timestamp,
          linkingHandler: linkingHandler,
          readingHandler: readingHandler,
          handler: completion
        )
      },
      resolver: resolve
    )
  }

  func purchaseVoid(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    runVoidWithTap(params, isRefundVoid: false, resolver: resolve)
  }

  func refundVoid(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    runVoidWithTap(params, isRefundVoid: true, resolver: resolve)
  }

  private func runVoidWithTap(
    _ params: NSDictionary,
    isRefundVoid: Bool,
    resolver resolve: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    guard let originalIntentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    let scheme = paymentCardScheme(from: dictionary["scheme"])
    let timestamp = timeIntervalValue(from: dictionary["timestamp"]
      ?? dictionary["timeStamp"]
      ?? dictionary["time_stamp"])
    let customerReferenceNumber = customerReference(from: dictionary)

    startTransaction(
      intentId: originalIntentId,
      event: isRefundVoid ? .refundVoidEvent : .purchaseVoidEvent,
      successType: "onSendTransactionCompleted",
      failureType: "sendTransactionFailure",
      start: { linkingHandler, readingHandler, completion in
        if isRefundVoid {
          terminal.refundVoid(
            originalIntentID: originalIntentId,
            amount: amount,
            customerReferenceNumber: customerReferenceNumber,
            scheme: scheme,
            timestamp: timestamp,
            linkingHandler: linkingHandler,
            readingHandler: readingHandler,
            handler: completion
          )
        } else {
          terminal.purchaseVoid(
            originalIntentID: originalIntentId,
            amount: amount,
            customerReferenceNumber: customerReferenceNumber,
            scheme: scheme,
            timestamp: timestamp,
            linkingHandler: linkingHandler,
            readingHandler: readingHandler,
            handler: completion
          )
        }
      },
      resolver: resolve
    )
  }

  func cancelTransaction(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let id = uuidValue(from: dictionary["id"]
      ?? dictionary["transactionUuid"]
      ?? dictionary["transactionUUID"]
      ?? dictionary["intentId"]
      ?? dictionary["intentUUID"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    DispatchQueue.main.async {
      terminal.cancelTransaction(with: id) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            resolve(self.responseHandlerSuccess(message: BridgeMessages.transactionCancelled))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "CANCEL_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func reverseTransaction(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let originalIntentId = uuidValue(from: dictionary["intentId"]
      ?? dictionary["intentUUID"]
      ?? dictionary["intentUuid"]
      ?? dictionary["originalIntentId"]
      ?? dictionary["originalIntentID"]
      ?? dictionary["originalJobId"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentIdParam))
      return
    }

    DispatchQueue.main.async {
      terminal.reverse(originalIntentID: originalIntentId) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            resolve(self.responseHandlerSuccess(message: BridgeMessages.reverseSuccessful, data: self.serializeTransactionResponse(response)))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "REVERSE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func capture(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    let originalValue = dictionary["authorizationUUID"] ?? dictionary["authorizationUuid"]
    guard let originalIdString = stringValue(from: originalValue), let originalIntentId = UUID(uuidString: originalIdString) else {
      resolve(responseHandlerError(code: "MISSING_AUTHORIZATION_UUID", message: BridgeMessages.missingAuthorizationUUID))
      return
    }

    DispatchQueue.main.async {
      terminal.capture(originalIntentID: originalIntentId, amount: amount) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            resolve(self.responseHandlerSuccess(message: BridgeMessages.captureAuthorizationSuccessful, data: self.serializeTransactionResponse(response)))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "CAPTURE_FAILED",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func increment(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    let originalValue = dictionary["authorizationUUID"]
      ?? dictionary["authorizationUuid"]
      ?? dictionary["originalJobId"]
      ?? dictionary["originalIntentId"]
      ?? dictionary["originalIntentID"]
    guard let originalIdString = stringValue(from: originalValue), let originalIntentId = UUID(uuidString: originalIdString) else {
      resolve(responseHandlerError(code: "MISSING_AUTH_UUID", message: BridgeMessages.missingAuthUuidParam))
      return
    }

    DispatchQueue.main.async {
      terminal.increment(originalIntentID: originalIntentId, amount: amount) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            resolve(self.responseHandlerSuccess(message: BridgeMessages.incrementSuccessful, data: self.serializeTransactionResponse(response)))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "INCREMENT_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func tipTransaction(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let amount = uint64Value(from: dictionary["amount"]) else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    let originalValue = dictionary["id"]
      ?? dictionary["transactionUUID"]
      ?? dictionary["transactionUuid"]
    guard let originalIdString = stringValue(from: originalValue), let originalIntentId = UUID(uuidString: originalIdString) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    DispatchQueue.main.async {
      terminal.tip(originalIntentID: originalIntentId, amount: amount) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            resolve(self.responseHandlerSuccess(message: BridgeMessages.tipSuccessful, data: self.serializeTransactionResponse(response)))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "TIP_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func voidAuthorization(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let originalIntentId = uuidValue(from: dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingTransactionId))
      return
    }

    DispatchQueue.main.async {
      terminal.void(originalIntentID: originalIntentId) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            resolve(self.responseHandlerSuccess(message: BridgeMessages.voidAuthorizationSuccessful, data: self.serializeTransactionResponse(response)))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "VOID_AUTHORIZATION_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }
}

extension NearpayFlutterBridge {
  func reconcile(
    _ resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    DispatchQueue.main.async {
      terminal.reconcile { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            guard let payload = self.wrapReconciliationReceipt(response) else {
              resolve(self.responseHandlerError(code: "RECONCILE_EMPTY", message: BridgeMessages.noReceiptReturned))
              return
            }
            resolve(self.responseHandlerSuccess(message: BridgeMessages.reconcileSuccessful, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "RECONCILE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getReconcileList(
    _ queryParams: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    getReconciliationList(queryParams, resolver: resolve, rejecter: reject)
  }

  func getReconcileDetails(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    fetchReconciliation(params, wrapped: true, resolver: resolve, rejecter: reject)
  }

  func getPendingTotal(
    _ _: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    DispatchQueue.main.async {
      terminal.getPendingTotal { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload: [String: Any] = [
              "pendingTotal": response.total,
              "total": response.total,
              "currency": self.serializeLocalizationField(response.currency),
              "responseType": "GetPendingTotal"
            ]
            resolve(self.responseHandlerSuccess(message: BridgeMessages.pendingTotalRetrieved, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_PENDING_TOTAL_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getReconciliationList(
    _ queryParams: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let queryDictionary = dictionary(from: queryParams)
    if rejectedInvalidDate(in: queryDictionary, resolve: resolve) { return }
    let query = makeReconciliationListQuery(from: queryDictionary)

    DispatchQueue.main.async {
      let completion: ReconciliationListHandler = { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeReconciliationListResponse(response) ?? [:]
            resolve(self.responseHandlerSuccess(message: BridgeMessages.reconciliationListFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "RECONCILIATION_LIST_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }

      if let query = query {
        terminal.getReconciliationList(query: query, handler: completion)
      } else {
        terminal.getReconciliationList(handler: completion)
      }
    }
  }

  func getReconciliation(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    fetchReconciliation(params, wrapped: false, resolver: resolve, rejecter: reject)
  }

  private func fetchReconciliation(
    _ params: NSDictionary?,
    wrapped: Bool,
    resolver resolve: @escaping FlutterResult,
    rejecter reject: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    let reconciliationIdString = stringValue(from: dictionary["reconciliationId"]
      ?? dictionary["uuid"])
    guard let reconciliationIdString, let reconciliationID = UUID(uuidString: reconciliationIdString) else {
      resolve(responseHandlerError(code: "INVALID_UUID", message: BridgeMessages.missingReconciliationId))
      return
    }

    DispatchQueue.main.async {
      terminal.getReconciliation(with: reconciliationID) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let candidate = wrapped
              ? ResponseSerializer.wrapReconciliationReceipt(response)
              : self.flutterFlatReconciliationPayload(response)
            guard let payload = candidate else {
              resolve(self.responseHandlerError(code: "RECONCILIATION_EMPTY", message: BridgeMessages.noReceiptReturned))
              return
            }
            resolve(self.responseHandlerSuccess(message: BridgeMessages.reconciliationFetched, data: payload))
          case .failure(let error):
            let message = self.errorMessage(from: error)
            if self.shouldFallbackReconciliationFetch(message) {
              self.fetchReconciliationFallbackFromList(
                terminal: terminal,
                reconciliationID: reconciliationID,
                originalErrorMessage: message,
                wrapped: wrapped,
                resolver: resolve
              )
              return
            }
            resolve(
              self.responseHandlerError(
                code: "RECONCILIATION_FETCH_FAILURE",
                message: message,
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }
}

extension NearpayFlutterBridge {
  func getIntentList(
    _ queryParams: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let queryDictionary = dictionary(from: queryParams)
    if rejectedInvalidDate(in: queryDictionary, resolve: resolve) { return }
    let query = makeTransactionListQuery(from: queryDictionary)

    DispatchQueue.main.async {
      let completion: IntentListHandler = { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeIntentListResponse(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.intentListFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_INTENT_LIST_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }

      if let query = query {
        terminal.getIntentList(query: query, handler: completion)
      } else {
        terminal.getIntentList(handler: completion)
      }
    }
  }

  func getIntentDetails(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let intentId = uuidValue(from: dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_INTENT_UUID", message: BridgeMessages.missingIntentUUID))
      return
    }

    DispatchQueue.main.async {
      terminal.getIntent(with: intentId) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeIntentDetails(response.details)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.intentDetailsFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_INTENT_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

}

extension NearpayFlutterBridge {
  func createInvoice(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let items = invoiceItems(from: dictionary["items"]) else {
      resolve(responseHandlerError(code: "MISSING_ITEMS", message: BridgeMessages.missingInvoiceItems))
      return
    }
    guard
      let vatPercentage = doubleValue(from: dictionary["vatPercentage"]
        ?? dictionary["vat_percentage"])
    else {
      resolve(responseHandlerError(code: "MISSING_VAT_PERCENTAGE", message: BridgeMessages.missingVatPercentage))
      return
    }

    guard
      let paymentTypeRaw = stringValue(from: dictionary["type"]
        ?? dictionary["paymentType"]
        ?? dictionary["payment_type"]),
      let paymentType = paymentType(from: paymentTypeRaw)
    else {
      resolve(responseHandlerError(code: "INVALID_PAYMENT_TYPE", message: BridgeMessages.invalidPaymentType))
      return
    }

    let paidAmount = doubleValue(from: dictionary["paidAmount"]
      ?? dictionary["paid_amount"])
    let discountPercentage = doubleValue(from: dictionary["discountPercentage"]
      ?? dictionary["discount_percentage"])
    let discount = doubleValue(from: dictionary["discount"])
    let request = InvoiceRequest(
      items: items,
      vatPercentage: vatPercentage,
      type: paymentType,
      paidAmount: paidAmount,
      discountPercentage: discountPercentage,
      discount: discount
    )

    DispatchQueue.main.async {
      terminal.createInvoice(request: request) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeInvoiceResponse(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.invoiceCreated, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "CREATE_INVOICE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getInvoiceList(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let query = makeListQuery(from: params as? [String: Any])

    DispatchQueue.main.async {
      terminal.getInvoiceList(query: query) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeInvoiceListResponse(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.invoiceListFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_INVOICE_LIST_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getInvoice(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let invoiceID = uuidValue(from: dictionary["invoiceId"]
      ?? dictionary["invoice_id"]
      ?? dictionary["invoiceUUID"]
      ?? dictionary["invoice_uuid"]
      ?? dictionary["id"]
      ?? dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "INVALID_INVOICE_ID", message: BridgeMessages.missingInvoiceId))
      return
    }

    DispatchQueue.main.async {
      terminal.getInvoice(with: invoiceID) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeInvoiceDetails(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.invoiceFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_INVOICE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func createProduct(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard
      let rawName = rawStringValue(from: dictionary["name"]
        ?? dictionary["productName"]
        ?? dictionary["product_name"])
    else {
      resolve(responseHandlerError(code: "MISSING_PRODUCT_NAME", message: BridgeMessages.missingProductName))
      return
    }

    let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_PRODUCT_NAME", message: BridgeMessages.missingProductName))
      return
    }

    guard
      let price = doubleValue(from: dictionary["price"]),
      price.isFinite,
      price >= 0
    else {
      resolve(responseHandlerError(code: "MISSING_PRODUCT_PRICE", message: BridgeMessages.missingProductPrice))
      return
    }

    let description = rawStringValue(from: dictionary["description"]
      ?? dictionary["productDescription"]
      ?? dictionary["product_description"]) ?? ""
    let isVATExcluded = boolValue(from: dictionary["isVATExcluded"]
      ?? dictionary["vatExcluded"]
      ?? dictionary["vat_excluded"]
      ?? dictionary["is_vat_excluded"]) ?? false
    let request = ProductRequest(
      name: name,
      description: description,
      price: price,
      isVATExcluded: isVATExcluded
    )

    DispatchQueue.main.async {
      terminal.createProduct(request: request) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeProductDetails(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.productCreated, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "CREATE_PRODUCT_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getAllProducts(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let queryDictionary = params as? [String: Any]
    let query = makeListQuery(from: queryDictionary)

    DispatchQueue.main.async {
      terminal.getProductList(query: query) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeProductListResponse(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.productsFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_ALL_PRODUCTS_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func getProduct(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let productID = uuidValue(from: dictionary["productId"]
      ?? dictionary["product_id"]
      ?? dictionary["id"]
      ?? dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_PRODUCT_ID", message: BridgeMessages.missingProductId))
      return
    }

    DispatchQueue.main.async {
      terminal.getProduct(with: productID) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeProductDetails(response)
            resolve(self.responseHandlerSuccess(message: BridgeMessages.productFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GET_PRODUCT_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func deleteProduct(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let productID = uuidValue(from: dictionary["productId"]
      ?? dictionary["product_id"]
      ?? dictionary["id"]
      ?? dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "MISSING_PRODUCT_ID", message: BridgeMessages.missingProductId))
      return
    }

    DispatchQueue.main.async {
      terminal.deleteProduct(with: productID) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            resolve(self.responseHandlerSuccess(message: BridgeMessages.productDeleted))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "DELETE_PRODUCT_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }
}

extension NearpayFlutterBridge {
  func getTerminalConfig(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = requireTerminal(
      forUUIDIn: params as? [String: Any] ?? [:],
      resolver: resolve
    ) else {
      return
    }

    DispatchQueue.main.async {
      terminal.getConfiguration { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let response):
            let payload = self.serializeTerminalConfigResponse(response) ?? [:]
            resolve(self.responseHandlerSuccess(message: BridgeMessages.terminalConfigFetched, data: payload))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "TERMINAL_CONFIG_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func shareReceipt(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let receiptTypeRaw = stringValue(from: dictionary["receiptType"]
      ?? dictionary["receipt_type"]
      ?? dictionary["type"]) else {
      resolve(responseHandlerError(code: "MISSING_RECEIPT_TYPE", message: BridgeMessages.missingReceiptType))
      return
    }

    guard let receiptID = uuidValue(from: dictionary["receiptId"]
      ?? dictionary["receipt_id"]
      ?? dictionary["invoiceId"]
      ?? dictionary["invoice_id"]
      ?? dictionary["transactionId"]
      ?? dictionary["transaction_id"]
      ?? dictionary["id"]
      ?? dictionary["uuid"]) else {
      resolve(responseHandlerError(code: "INVALID_RECEIPT_ID", message: BridgeMessages.missingReceiptId))
      return
    }

    let receiptType: TerminalSDK.ReceiptType
    switch receiptTypeRaw.lowercased() {
    case "invoice":
      receiptType = .invoice(receiptID)
    case "transaction":
      receiptType = .transaction(receiptID)
    default:
      resolve(responseHandlerError(code: "INVALID_RECEIPT_TYPE", message: BridgeMessages.invalidReceiptType))
      return
    }

    let methodPayload = dictionary["method"] as? [String: Any]
    guard let methodRaw = stringValue(from: methodPayload?["type"]
      ?? methodPayload?["method"]
      ?? dictionary["method"]
      ?? dictionary["shareMethod"]
      ?? dictionary["share_method"]) else {
      resolve(responseHandlerError(code: "MISSING_SHARE_METHOD", message: BridgeMessages.missingShareMethod))
      return
    }

    guard let destination = stringValue(from: methodPayload?["value"]
      ?? methodPayload?["mobile"]
      ?? methodPayload?["email"]
      ?? dictionary["value"]
      ?? dictionary["recipient"]
      ?? dictionary["mobile"]
      ?? dictionary["email"]) else {
      resolve(responseHandlerError(code: "MISSING_SHARE_VALUE", message: BridgeMessages.missingShareValue))
      return
    }

    let shareMethod: TerminalSDK.ReceiptShareMethod
    switch methodRaw.lowercased() {
    case "mobile":
      shareMethod = .mobile(destination)
    case "email":
      shareMethod = .email(destination)
    default:
      resolve(responseHandlerError(code: "INVALID_SHARE_METHOD", message: BridgeMessages.invalidShareMethod))
      return
    }

    DispatchQueue.main.async {
      terminal.shareReceipt(of: receiptType, method: shareMethod) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success:
            resolve(self.responseHandlerSuccess(message: BridgeMessages.receiptShared))
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "SHARE_RECEIPT_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }
}

extension NearpayFlutterBridge {
  func generateQrCode(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let intentId = uuidValue(from: dictionary["id"]
      ?? dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    guard let amount = stringValue(from: dictionary["amount"]), !amount.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    let customerReferenceNumber = stringValue(from: dictionary["customerReferenceNumber"]
      ?? dictionary["customer_reference_number"])
    let latitude = doubleValue(from: dictionary["lat"] ?? dictionary["latitude"])
    let longitude = doubleValue(from: dictionary["long"] ?? dictionary["longitude"])
    let isLocationFromMock = boolValue(from: dictionary["isLocationFromMock"]
      ?? dictionary["is_location_from_mock"])

    DispatchQueue.main.async {
      terminal.generateQrCode(
        id: intentId,
        amount: amount,
        customerReferenceNumber: customerReferenceNumber,
        latitude: latitude,
        longitude: longitude,
        isLocationFromMock: isLocationFromMock
      ) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let qrCode):
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.qrCodeGenerated,
                data: ResponseSerializer.serializeGeneratedQRCode(qrCode)
              )
            )
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "GENERATE_QR_CODE_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func qrStatus(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let transactionId = stringValue(from: dictionary["transactionId"]
      ?? dictionary["id"]
      ?? dictionary["transactionUUID"]
      ?? dictionary["transactionUuid"]), !transactionId.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_TRANSACTION_ID", message: BridgeMessages.transactionIdParamRequired))
      return
    }

    let intentID = uuidValue(from: dictionary["intentId"])

    DispatchQueue.main.async {
      terminal.qrStatus(transactionID: transactionId, intentID: intentID) { [weak self] result in
        DispatchQueue.main.async {
          guard let self else {
            resolve(Self.settledModuleReleasedResponse())
            return
          }
          switch result {
          case .success(let status):
            resolve(
              self.responseHandlerSuccess(
                message: BridgeMessages.qrStatusFetched,
                data: ResponseSerializer.serializeQrStatusResponse(status)
              )
            )
          case .failure(let error):
            resolve(
              self.responseHandlerError(
                code: "QR_STATUS_FAILURE",
                message: self.errorMessage(from: error),
                underlyingError: error
              )
            )
          }
        }
      }
    }
  }

  func generateQrCodeWithUi(
    _ params: NSDictionary?,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    let dictionary = params as? [String: Any] ?? [:]
    guard let intentId = uuidValue(from: dictionary["id"]
      ?? dictionary["intentUUID"]
      ?? dictionary["intentUuid"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    guard let amount = stringValue(from: dictionary["amount"]), !amount.isEmpty else {
      resolve(responseHandlerError(code: "MISSING_AMOUNT", message: BridgeMessages.missingAmount))
      return
    }

    let requestId = stringValue(from: dictionary["requestId"])
      ?? stringValue(from: dictionary["id"])
      ?? UUID().uuidString
    let customerReferenceNumber = stringValue(from: dictionary["customerReferenceNumber"]
      ?? dictionary["customer_reference_number"])
    let enableUiDismiss = boolValue(from: dictionary["enableUiDismiss"]
      ?? dictionary["enable_ui_dismiss"]) ?? true
    let latitude = doubleValue(from: dictionary["lat"] ?? dictionary["latitude"])
    let longitude = doubleValue(from: dictionary["long"] ?? dictionary["longitude"])
    let isLocationFromMock = boolValue(from: dictionary["isLocationFromMock"]
      ?? dictionary["is_location_from_mock"])

    let listener = QrPaymentUiListenerAdapter(
      emit: { [weak self] type, message, data in
        self?.emitQrPaymentEvent(requestId: requestId, type: type, message: message, data: data)
      },
      onPresented: { [weak self] in
        self?.setQrPaymentHostInteractive(true)
      },
      onDismissUi: { [weak self] in
        self?.dismissQrPaymentHost()
      },
      onSettled: { [weak self] in
        self?.qrPaymentUiListeners.removeValue(forKey: requestId)
      }
    )
    if qrPaymentUiListeners[requestId] != nil {
      dismissQrPaymentHost()
    }
    qrPaymentUiListeners[requestId] = listener

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard self.presentQrPaymentHost() else {
        listener.onQrPaymentFailure(message: "Unable to present QR payment UI")
        return
      }
      terminal.generateQrCodeWithUi(
        id: intentId,
        amount: amount,
        customerReferenceNumber: customerReferenceNumber,
        latitude: latitude,
        longitude: longitude,
        isLocationFromMock: isLocationFromMock,
        enableUiDismiss: enableUiDismiss,
        listener: listener
      )
    }

    resolve(
      responseHandlerSuccess(
        message: BridgeMessages.qrPaymentUiStarted,
        data: ["requestId": requestId, "responseType": "GenerateQrCodeWithUi"]
      )
    )
  }

  func qrVoid(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentId"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    guard let originalIntentId = uuidValue(
      from: dictionary["originalIntentId"] ?? dictionary["originalIntentID"]
    ) else {
      resolve(
        responseHandlerError(
          code: "MISSING_ORIGINAL_INTENT_ID",
          message: BridgeMessages.missingOriginalIntentId
        )
      )
      return
    }

    let requestId = stringValue(from: dictionary["requestId"]) ?? UUID().uuidString
    let latitude = doubleValue(from: dictionary["lat"] ?? dictionary["latitude"])
    let longitude = doubleValue(from: dictionary["long"] ?? dictionary["longitude"])
    let isLocationFromMock = boolValue(from: dictionary["isLocationFromMock"]
      ?? dictionary["is_location_from_mock"])

    let listener = QrVoidListenerAdapter(
      emit: { [weak self] type, message, data in
        self?.emitQrVoidEvent(requestId: requestId, type: type, message: message, data: data)
      },
      onPresented: { [weak self] in
        self?.setQrPaymentHostInteractive(true)
      },
      onDismissUi: { [weak self] in
        self?.dismissQrPaymentHost()
      },
      onSettled: { [weak self] in
        self?.qrVoidListeners.removeValue(forKey: requestId)
      }
    )
    if qrVoidListeners[requestId] != nil {
      dismissQrPaymentHost()
    }
    qrVoidListeners[requestId] = listener

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard self.presentQrPaymentHost() else {
        listener.onQrVoidFailure(message: "Unable to present QR void UI")
        resolve(
          self.responseHandlerSuccess(
            message: BridgeMessages.transactionStarted,
            data: ["requestId": requestId]
          )
        )
        return
      }
      terminal.qrVoid(
        intentID: intentId,
        originalIntentID: originalIntentId,
        latitude: latitude,
        longitude: longitude,
        isLocationFromMock: isLocationFromMock,
        listener: listener
      )
      resolve(
        self.responseHandlerSuccess(
          message: BridgeMessages.transactionStarted,
          data: ["requestId": requestId]
        )
      )
    }
  }

  func qrRefund(
    _ params: NSDictionary,
    resolver resolve: @escaping FlutterResult,
    rejecter _: @escaping FlutterResult
  ) {
    guard let terminal = currentTerminal else {
      resolve(responseHandlerError(code: "TERMINAL_NOT_FOUND", message: BridgeMessages.noConnectedTerminal))
      return
    }

    guard let dictionary = params as? [String: Any] else {
      resolve(responseHandlerError(code: "MISSING_PARAMS", message: BridgeMessages.paramsRequired))
      return
    }

    guard let intentId = uuidValue(from: dictionary["intentId"] ?? dictionary["intentID"]) else {
      resolve(responseHandlerError(code: "MISSING_ID", message: BridgeMessages.missingId))
      return
    }

    guard let originalIntentId = uuidValue(
      from: dictionary["originalIntentId"] ?? dictionary["originalIntentID"]
    ) else {
      resolve(
        responseHandlerError(
          code: "MISSING_ORIGINAL_INTENT_ID",
          message: BridgeMessages.missingOriginalIntentId
        )
      )
      return
    }

    let requestId = stringValue(from: dictionary["requestId"]) ?? UUID().uuidString
    let amount = stringValue(from: dictionary["amount"])?.trimmingCharacters(in: .whitespaces)
    let enableUiDismiss = boolValue(from: dictionary["enableUiDismiss"]
      ?? dictionary["enable_ui_dismiss"]) ?? true

    let listener = QrRefundListenerAdapter(
      emit: { [weak self] type, message, data in
        self?.emitQrRefundEvent(requestId: requestId, type: type, message: message, data: data)
      },
      onPresented: { [weak self] in
        self?.setQrPaymentHostInteractive(true)
      },
      onDismissUi: { [weak self] in
        self?.dismissQrPaymentHost()
      },
      onSettled: { [weak self] in
        self?.qrRefundListeners.removeValue(forKey: requestId)
      }
    )
    if qrRefundListeners[requestId] != nil {
      dismissQrPaymentHost()
    }
    qrRefundListeners[requestId] = listener

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard self.presentQrPaymentHost() else {
        listener.onQrRefundFailure(message: "Unable to present QR refund UI")
        resolve(
          self.responseHandlerSuccess(
            message: BridgeMessages.transactionStarted,
            data: ["requestId": requestId]
          )
        )
        return
      }
      terminal.qrRefund(
        intentID: intentId,
        originalIntentID: originalIntentId,
        amount: (amount?.isEmpty == false) ? amount : nil,
        enableUiDismiss: enableUiDismiss,
        listener: listener
      )
      resolve(
        self.responseHandlerSuccess(
          message: BridgeMessages.transactionStarted,
          data: ["requestId": requestId]
        )
      )
    }
  }
}

private final class QrPaymentUiListenerAdapter: QrPaymentUiListener {
  private let emit: (_ type: String, _ message: String?, _ data: Any?) -> Void
  private let onPresented: () -> Void
  private let onDismissUi: () -> Void
  private let onSettled: () -> Void
  private var didPresentSheet = false

  init(
    emit: @escaping (_ type: String, _ message: String?, _ data: Any?) -> Void,
    onPresented: @escaping () -> Void,
    onDismissUi: @escaping () -> Void,
    onSettled: @escaping () -> Void
  ) {
    self.emit = emit
    self.onPresented = onPresented
    self.onDismissUi = onDismissUi
    self.onSettled = onSettled
  }

  func onQrUiPresented(qrCode: GeneratedQRCode) {
    didPresentSheet = true
    onPresented()
    emit("onQrUiPresented", nil, ResponseSerializer.serializeGeneratedQRCode(qrCode))
  }

  func onUiClosed() {
    didPresentSheet = false
    onDismissUi()
    emit("onUiClosed", nil, nil)
    onSettled()
  }

  func onQrPaymentFailure(message: String) {
    emit("onQrPaymentFailure", message, nil)
    if didPresentSheet {
      return
    }
    onDismissUi()
    onSettled()
  }

  func onQrPaymentStatusUpdated(status: QrStatusResponse) {
    emit("onQrPaymentStatusUpdated", nil, ResponseSerializer.serializeQrStatusResponse(status))
  }

  func onQrPaymentStatusCompleted(status: QrStatusResponse) {
    emit("onQrPaymentStatusCompleted", nil, ResponseSerializer.serializeQrStatusResponse(status))
    onSettled()
  }

  func onQrPaymentStatusFailed(status: QrStatusResponse) {
    emit("onQrPaymentStatusFailed", nil, ResponseSerializer.serializeQrStatusResponse(status))
    onSettled()
  }

  func onQrPaymentStatusExpired(status: QrStatusResponse) {
    emit("onQrPaymentStatusExpired", nil, ResponseSerializer.serializeQrStatusResponse(status))
    onSettled()
  }

  func onQrPaymentStatusCancelled(status: QrStatusResponse) {
    emit("onQrPaymentStatusCancelled", nil, ResponseSerializer.serializeQrStatusResponse(status))
    onSettled()
  }
}

private final class QrVoidListenerAdapter: QrVoidListener {
  private let emit: (_ type: String, _ message: String?, _ data: Any?) -> Void
  private let onPresented: () -> Void
  private let onDismissUi: () -> Void
  private let onSettled: () -> Void
  private var didPresentSheet = false
  private var didClose = false

  init(
    emit: @escaping (_ type: String, _ message: String?, _ data: Any?) -> Void,
    onPresented: @escaping () -> Void,
    onDismissUi: @escaping () -> Void,
    onSettled: @escaping () -> Void
  ) {
    self.emit = emit
    self.onPresented = onPresented
    self.onDismissUi = onDismissUi
    self.onSettled = onSettled
  }

  func onQrVoidQrCodeGenerated(qrCode: GeneratedQRCode) {
    emit("onQrVoidQrCodeGenerated", nil, ResponseSerializer.serializeGeneratedQRCode(qrCode))
  }

  func onQrUiPresented(qrCode: GeneratedQRCode) {
    didPresentSheet = true
    onPresented()
    emit("onQrUiPresented", nil, ResponseSerializer.serializeGeneratedQRCode(qrCode))
  }

  func onUiClosed() {
    closeUi()
  }

  func onQrVoidSuccess(status: QrStatusResponse) {
    emit("onQrVoidSuccess", nil, ResponseSerializer.serializeQrStatusResponse(status))
    if !didPresentSheet {
      closeUi()
    }
  }

  func onQrVoidFailure(message: String) {
    emit("onQrVoidFailure", message, nil)
    if !didPresentSheet {
      closeUi()
    }
  }

  private func closeUi() {
    guard !didClose else { return }
    didClose = true
    didPresentSheet = false
    onDismissUi()
    emit("onUiClosed", nil, nil)
    onSettled()
  }
}

private final class QrRefundListenerAdapter: QrRefundListener {
  private let emit: (_ type: String, _ message: String?, _ data: Any?) -> Void
  private let onPresented: () -> Void
  private let onDismissUi: () -> Void
  private let onSettled: () -> Void
  private var didPresentSheet = false
  private var didClose = false

  init(
    emit: @escaping (_ type: String, _ message: String?, _ data: Any?) -> Void,
    onPresented: @escaping () -> Void,
    onDismissUi: @escaping () -> Void,
    onSettled: @escaping () -> Void
  ) {
    self.emit = emit
    self.onPresented = onPresented
    self.onDismissUi = onDismissUi
    self.onSettled = onSettled
  }

  func onQrRefundQrCodeGenerated(qrCode: GeneratedQRCode) {
    emit("onQrRefundQrCodeGenerated", nil, ResponseSerializer.serializeGeneratedQRCode(qrCode))
  }

  func onQrUiPresented(qrCode: GeneratedQRCode) {
    didPresentSheet = true
    onPresented()
    emit("onQrUiPresented", nil, ResponseSerializer.serializeGeneratedQRCode(qrCode))
  }

  func onUiClosed() {
    closeUi()
  }

  func onQrRefundSuccess(status: QrStatusResponse) {
    emit("onQrRefundSuccess", nil, ResponseSerializer.serializeQrStatusResponse(status))
    if !didPresentSheet {
      closeUi()
    }
  }

  func onQrRefundFailure(message: String) {
    emit("onQrRefundFailure", message, nil)
    if !didPresentSheet {
      closeUi()
    }
  }

  private func closeUi() {
    guard !didClose else { return }
    didClose = true
    didPresentSheet = false
    onDismissUi()
    emit("onUiClosed", nil, nil)
    onSettled()
  }
}

struct QrPaymentHostRoot: View {
  var body: some View {
    Color.clear
      .ignoresSafeArea()
      .qrPaymentView
  }
}
