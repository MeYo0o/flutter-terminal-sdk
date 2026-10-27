import Foundation
import TerminalSDK

enum ResponseSerializer {

  static func serializeTransactionResponse(_ response: TransactionResponse) -> [String: Any] {
    [
      "status": response.status,
      "details": serializeIntentDetails(response.details)
    ]
  }

  static func serializeIntentDetails(_ details: TransactionResponse.IntentDetails) -> [String: Any] {
    var payload: [String: Any] = [
      "intentId": details.intentID.uuidString,
      "pinRequired": details.pinRequired,
      "transactions": details.transactions.map(serializeTransactionDetails)
    ]

    payload["referenceId"] = details.referenceID ?? NSNull()
    payload["type"] = details.type ?? NSNull()
    payload["status"] = details.status ?? NSNull()
    payload["amount"] = details.amount ?? NSNull()
    payload["createdAt"] = details.createdAt ?? NSNull()
    payload["completedAt"] = details.completedAt ?? NSNull()
    payload["canceledAt"] = details.canceledAt ?? NSNull()
    payload["isReconciled"] = details.isReconciled
    payload["receiptsUrl"] = details.groupReceiptsURL ?? NSNull()

    return payload
  }

  static func serializeTransactionDetails(_ transaction: TransactionDetails) -> [String: Any] {
    let encodedTransaction = BridgeSerialization.encodeToJSONObject(transaction) as? [String: Any] ?? [:]
    let cardPayload: Any = transaction.card.map { card in
      [
        "pan": card.pan,
        "exp": card.exp,
        "brandCode": card.brandCode ?? NSNull(),
        "panSuffix": card.panSuffix ?? NSNull()
      ] as [String: Any]
    } ?? NSNull()
    var currencyPayload: Any = NSNull()
    if let currency = transaction.currency {
      currencyPayload = [
        "english": currency,
        "arabic": currency,
        "turkish": currency
      ]
    }
    var payload: [String: Any] = [
      "id": transaction.id.uuidString,
      "status": transaction.status.rawValue,
      "createdAt": transaction.createdAt ?? NSNull(),
      "amount": transaction.amount,
      "currency": currencyPayload,
      "completedAt": transaction.completedAt ?? NSNull(),
      "pinRequired": transaction.pinRequired,
      "card": cardPayload,
      "events": transaction.events.map(serializeTransactionEvent)
    ]

    payload["groupReceiptsUrl"] = transaction.groupReceiptsURL ?? NSNull()
    payload["referenceId"] = transaction.referenceID ?? NSNull()
    payload["orderId"] = transaction.orderID ?? NSNull()
    payload["approvalCode"] = transaction.approvalCode ?? NSNull()
    payload["attempts"] = transaction.attempts ?? NSNull()
    payload["performance"] = camelCaseKeysDeep(encodedTransaction["performance"] ?? NSNull())
    payload["cancelReason"] = encodedTransaction["cancelReason"]
      ?? encodedTransaction["cancel_reason"]
      ?? NSNull()
    payload["amountOther"] = encodedTransaction["amountOther"]
      ?? encodedTransaction["amount_other"]
      ?? NSNull()
    payload["canceledAt"] = encodedTransaction["canceledAt"]
      ?? encodedTransaction["canceled_at"]
      ?? NSNull()

    return payload
  }

  static func serializePerformance(_ performance: Performance) -> [String: Any] {
    [
      "type": performance.type,
      "time_stamp": performance.timeStamp
    ]
  }

  static func serializeTransactionEvent(_ event: TransactionEvent) -> [String: Any] {
    var payload: [String: Any] = [
      "status": event.status.rawValue,
      "receipt": event.receipt.map(serializeTransactionReceipt) ?? NSNull()
    ]

    payload["rrn"] = event.rrn ?? NSNull()
    payload["stan"] = event.stan ?? NSNull()
    payload["type"] = event.type ?? NSNull()

    return payload
  }

  static func serializeTransactionReceipt(_ receipt: TransactionEvent.Receipt) -> [String: Any] {
    var payload: [String: Any] = [
      "standard": receipt.type?.rawValue ?? NSNull()
    ]

    payload["id"] = receipt.id?.uuidString ?? NSNull()
    if let content = receiptContentPayload(receipt),
      !(content is NSNull),
      let jsonString = flutterJSONString(from: content) {
      payload["data"] = jsonString
    } else {
      payload["data"] = NSNull()
    }
    return payload
  }

  static func receiptContentPayload(_ receipt: TransactionEvent.Receipt) -> Any? {
    if let mada = try? receipt.content(type: TransactionReceipt.self) {
      return BridgeSerialization.encodeToJSONObject(mada) ?? NSNull()
    }
    if let usa = try? receipt.content(type: USTransactionReceipt.self) {
      return encodeUSTransactionReceipt(
        usa,
        rawData: rawReceiptDataDictionary(from: receipt)
      )
    }
    return rawReceiptDataDictionary(from: receipt)
  }

  static func serializeReconciliationReceipt(_ receipt: ReconciliationReceipt) -> [String: Any]? {
    BridgeSerialization.encodeToJSONObject(receipt) as? [String: Any]
  }

  static func serializeTransactionListResponse(_ response: TransactionListResponse) -> [String: Any]? {
    BridgeSerialization.encodeToJSONObject(response) as? [String: Any]
  }

  static func serializeGeneratedQRCode(_ qrCode: GeneratedQRCode) -> [String: Any] {
    [
      "qrCode": qrCode.qrCode,
      "transactionId": qrCode.transactionID,
      "amount": qrCode.amount,
      "responseType": "GenerateQrCode"
    ]
  }

  static func serializeQrStatusResponse(_ status: QrStatusResponse) -> [String: Any] {
    var payload: [String: Any] = [
      "statusRaw": status.statusRaw
    ]

    payload["id"] = status.id ?? NSNull()
    payload["message"] = status.message ?? NSNull()
    payload["authCode"] = status.authCode ?? NSNull()
    payload["actionCode"] = status.actionCode ?? NSNull()
    payload["rrn"] = status.rrn ?? NSNull()
    payload["stan"] = status.stan ?? NSNull()
    payload["amount"] = status.amount ?? NSNull()

    if let receipt = status.receipt {
      var receiptPayload: [String: Any] = [
        "standard": receipt.standard,
        "data": receipt.data
      ]
      receiptPayload["id"] = receipt.id ?? NSNull()
      payload["receipt"] = receiptPayload
    } else {
      payload["receipt"] = NSNull()
    }

    return payload
  }

  static func serializeIntentListResponse(_ response: IntentListResponse) -> [String: Any] {
    [
      "data": response.intentList.map(serializeIntentListItem),
      "pagination": serializePagination(response.pagination)
    ]
  }

  static func serializeIntentListItem(_ item: IntentItem) -> [String: Any] {
    var payload: [String: Any] = [
      "id": item.id.uuidString,
      "type": item.type
    ]

    payload["customer_reference_number"] = item.customerReferenceNumber ?? NSNull()
    payload["terminal_id"] = item.terminalID?.uuidString ?? NSNull()
    payload["amount"] = item.amount ?? NSNull()
    payload["original_intent_id"] = item.originalIntentID?.uuidString ?? NSNull()
    payload["status"] = item.status ?? NSNull()
    payload["created_at"] = item.createdAt ?? NSNull()
    payload["completed_at"] = item.completedAt ?? NSNull()
    payload["cancelled_at"] = item.cancelledAt ?? NSNull()
    payload["transactions"] = item.transactions?.map(serializeIntentListTransaction) ?? []

    return payload
  }

  static func serializeIntentListTransaction(_ details: TerminalSDK.IntentDetails) -> [String: Any] {
    var payload: [String: Any] = [
      "uuid": details.id.uuidString,
      "scheme": serializeLocalizationField(details.scheme),
      "amount_authorized": details.amountAuthorized,
      "currency": serializeIntentCurrency(details.currency),
      "isApproved": details.isApproved,
      "isReversed": details.isReversed,
      "isReconciled": details.isReconciled,
      "transaction_type": serializeLocalizationField(details.transactionType)
    ]

    payload["pan"] = details.pan ?? NSNull()
    payload["retrieval_reference_number"] = details.retrievalReferenceNumber ?? NSNull()
    payload["customer_reference_number"] = details.customerReferenceNumber ?? NSNull()

    return payload
  }

  static func serializeIntentCurrency(_ value: IntentCurrency?) -> Any {
    guard let value else { return NSNull() }

    var payload: [String: Any] = [:]
    payload["code"] = value.code ?? NSNull()
    payload["decimals"] = value.decimals ?? NSNull()
    payload["name"] = value.name ?? NSNull()
    payload["number"] = value.number ?? NSNull()

    return payload
  }

  static func serializeInvoiceItem(_ item: InvoiceItem) -> [String: Any] {
    var payload: [String: Any] = [
      "name": item.name,
      "unit_price": item.unitPrice,
      "quantity": item.quantity,
      "total_price": item.totalPrice,
      "vat": item.vat,
      "net_total": item.netTotal
    ]

    payload["id"] = item.id?.uuidString ?? NSNull()
    return payload
  }

  static func serializeInvoicePayment(_ payment: InvoicePayment) -> [String: Any] {
    var payload: [String: Any] = [
      "amount": payment.amount,
      "payment_type": payment.paymentType.rawValue
    ]

    payload["id"] = payment.id?.uuidString ?? NSNull()
    payload["created_at"] = payment.createdAt ?? NSNull()
    return payload
  }

  static func serializeInvoiceDetails(_ details: InvoiceDetails) -> [String: Any] {
    var payload: [String: Any] = [
      "id": details.id.uuidString,
      "sub_total": details.subTotal,
      "vat": details.vat,
      "net_total": details.netTotal
    ]

    payload["merchant_id"] = details.merchantID?.uuidString ?? NSNull()
    payload["terminal_id"] = details.terminalID?.uuidString ?? NSNull()
    payload["vat_amount"] = details.vatAmount ?? NSNull()
    payload["items_count"] = details.itemsCount ?? NSNull()
    payload["total"] = details.total ?? NSNull()
    payload["items"] = details.items?.map(serializeInvoiceItem) ?? []
    payload["payments"] = details.payments?.map(serializeInvoicePayment) ?? []

    return payload
  }

  static func serializeInvoiceResponse(_ response: InvoiceResponse) -> [String: Any] {
    var payload: [String: Any] = [
      "id": response.id.uuidString,
      "sub_total": response.subTotal,
      "vat": response.vat,
      "net_total": response.netTotal,
      "discount": response.discount,
      "discount_percentage": response.discountPercentage,
      "total_paid": response.totalPaid,
      "invoice_number": response.invoiceNumber,
      "merchant_name": response.merchantName,
      "merchant_address": response.merchantAddress,
      "mcc": response.mcc,
      "merchant_phone_number": response.merchantPhoneNumber,
      "tid": response.tid,
      "items": response.items.map(serializeInvoiceItem),
      "payments": response.payments.map(serializeInvoicePayment),
      "created_at": response.createdAt,
      "updated_at": response.updatedAt
    ]

    payload["vat_percentage"] = response.vatPercentage ?? NSNull()
    return payload
  }

  static func serializeInvoiceListResponse(_ response: InvoiceListResponse) -> [String: Any] {
    [
      "data": response.invoiceList.map(serializeInvoiceDetails),
      "pagination": serializePagination(response.pagination)
    ]
  }

  static func serializeProductListResponse(_ response: ProductListResponse) -> [String: Any] {
    let products = response.productList.map(serializeProductDetails)
    return [
      "data": products,
      "products": products,
      "pagination": serializePagination(response.pagination)
    ]
  }

  static func serializeProductDetails(_ product: ProductDetails) -> [String: Any] {
    var payload: [String: Any] = [
      "id": product.id.uuidString,
      "name": product.name,
      "description": product.description,
      "price": product.price,
      "type": product.type,
      "isVATExcluded": product.isVATExcluded
    ]

    payload["imageLink"] = product.imageLink ?? NSNull()
    return payload
  }

  static func serializeReconciliationListResponse(_ response: ReconciliationListResponse) -> [String: Any]? {
    let items = response.reconciliationList.map { item -> [String: Any] in
      var data: [String: Any] = [
        "id": item.id.uuidString,
        "date": item.date,
        "time": item.time,
        "startDate": item.startDate,
        "startTime": item.startTime,
        "total": item.total
      ]
      data["currency"] = BridgeSerialization.encodeToJSONObject(item.currency) ?? NSNull()
      data["isBalanced"] = BridgeSerialization.encodeToJSONObject(item.isBalanced) ?? NSNull()
      return data
    }
    return [
      "data": items,
      "pagination": serializePagination(response.pagination)
    ]
  }

  static func serializeTerminalConfigResponse(_ response: TerminalConfigurationResponse) -> [String: Any]? {
    var payload: [String: Any] = [
      "terminal": serializeTerminalConfigTerminal(response.terminal),
      "merchant": serializeTerminalConfigMerchant(response.merchant)
    ]
    payload["supportedOperations"] = response.supportedOperations ?? NSNull()
    return payload
  }

  static func serializeTerminalConfigTerminal(_ terminal: TerminalInfo) -> [String: Any] {
    [
      "id": terminal.id.uuidString,
      "tid": terminal.tid,
      "name": terminal.name ?? NSNull(),
      "currencyCode": terminal.currencyCode
    ]
  }

  static func serializeTerminalConfigMerchant(_ merchant: MerchantConfiguration) -> [String: Any] {
    var payload: [String: Any] = [
      "name": serializeLocalizationField(merchant.name),
      "address": serializeLocalizationField(merchant.address)
    ]
    payload["surchargeAmount"] = merchant.surchargeAmount ?? NSNull()
    payload["taxPercentage"] = merchant.taxPercentage ?? NSNull()
    payload["configuration"] = merchant.configuration.map { flags in
      [
        "invoiceMode": flags.invoiceMode ?? NSNull(),
        "cashDiscount": flags.cashDiscount ?? NSNull()
      ] as [String: Any]
    } ?? NSNull()
    return payload
  }

  static func serializeTransactionQueryResponse(_ response: TransactionQueryResponse) -> [String: Any]? {
    [
      "receipts": response.receipts.map(serializeTransactionQueryReceipt)
    ]
  }

  static func serializeTransactionQueryReceipt(_ receipt: TransactionQueryResponse.Receipt) -> [String: Any] {
    var payload: [String: Any] = [
      "id": receipt.id.uuidString
    ]

    payload["type"] = receipt.type ?? NSNull()
    payload["rrn"] = receipt.rrn ?? NSNull()
    payload["stan"] = receipt.stan ?? NSNull()
    payload["status"] = receipt.status ?? NSNull()
    payload["action_code"] = receipt.actionCode ?? NSNull()
    payload["auth_code"] = receipt.authCode ?? NSNull()
    payload["standard"] = receipt.standard ?? NSNull()
    payload["operation_type"] = receipt.operationType ?? NSNull()
    payload["transaction_uuid"] = receipt.transactionUUID?.uuidString ?? NSNull()
    payload["intent_uuid"] = receipt.intentUUID?.uuidString ?? NSNull()
    payload["data"] = transactionQueryReceiptContentPayload(receipt) ?? NSNull()

    return payload
  }

  static func transactionQueryReceiptContentPayload(_ receipt: TransactionQueryResponse.Receipt) -> Any? {
    if let mada = try? receipt.content(type: TransactionReceipt.self) {
      return BridgeSerialization.encodeToJSONObject(mada) ?? NSNull()
    }
    if let usa = try? receipt.content(type: USTransactionReceipt.self) {
      return encodeUSTransactionReceipt(
        usa,
        rawData: rawReceiptDataDictionary(from: receipt)
      )
    }
    return rawReceiptDataDictionary(from: receipt)
  }

  static func encodeUSTransactionReceipt(
    _ usa: USTransactionReceipt,
    rawData: [String: Any]?
  ) -> Any {
    guard var payload = BridgeSerialization.encodeToJSONObject(usa) as? [String: Any] else {
      return rawData ?? NSNull()
    }

    if payload["statusMessage"] == nil && payload["status_message"] == nil,
       let raw = rawData,
       let recovered = (raw["statusMessage"] ?? raw["status_message"]) {
      payload["statusMessage"] = recovered
      payload["status_message"] = recovered
    }

    return payload
  }

  static func rawReceiptDataDictionary(from receipt: TransactionEvent.Receipt) -> [String: Any]? {
    guard let dict = BridgeSerialization.encodeToJSONObject(receipt) as? [String: Any] else {
      return nil
    }
    return parseRawReceiptDataField(dict["data"])
  }

  static func rawReceiptDataDictionary(from receipt: TransactionQueryResponse.Receipt) -> [String: Any]? {
    guard let dict = BridgeSerialization.encodeToJSONObject(receipt) as? [String: Any] else {
      return nil
    }
    return parseRawReceiptDataField(dict["data"])
  }

  static func parseRawReceiptDataField(_ value: Any?) -> [String: Any]? {
    if let dict = value as? [String: Any] {
      return dict
    }
    if let string = value as? String,
       let bytes = string.data(using: .utf8),
       let parsed = (try? JSONSerialization.jsonObject(with: bytes)) as? [String: Any] {
      return parsed
    }
    return nil
  }

  static func wrapReconciliationReceipt(_ receipt: ReconciliationReceipt?) -> [String: Any]? {
    guard let receipt else { return nil }
    let payload = serializeReconciliationReceipt(receipt) ?? [:]
    let reconciliationId = receipt.reconciliation?.id.uuidString ?? receipt.id.uuidString

    let receiptWrapper: [String: Any] = [
      "id": receipt.id.uuidString,
      "standard": "standard",
      "operation_type": "reconciliation",
      "data": payload,
      "reconciliation": ["id": reconciliationId],
      "created_at": receipt.createdAt ?? NSNull(),
      "updated_at": receipt.updatedAt ?? NSNull()
    ]

    return [
      "receipt": receiptWrapper,
      "reconciliation_id": reconciliationId
    ]
  }

  static func wrapReconciliationReceipt(_ response: ReconciliationResponse?) -> [String: Any]? {
    guard let response else { return nil }
    let payload = reconciliationResponsePayload(response.receipt) ?? [:]
    let reconciliationId = extractReconciliationId(from: payload)
    let receiptId = BridgeSerialization.stringValue(from: payload["id"]) ?? reconciliationId

    let receiptWrapper: [String: Any] = [
      "id": receiptId,
      "standard": "standard",
      "operationType": "reconciliation",
      "data": payload,
      "reconciliation": ["id": reconciliationId],
      "createdAt": payload["created_at"] ?? payload["createdAt"] ?? "",
      "updatedAt": payload["updated_at"] ?? payload["updatedAt"] ?? ""
    ]

    return [
      "receipt": receiptWrapper,
      "reconciliation_id": reconciliationId
    ]
  }

  static func reconciliationListItemPayload(_ item: ReconciliationItem) -> [String: Any] {
    let reconciliationId = item.id.uuidString
    var data: [String: Any] = [
      "id": reconciliationId,
      "date": item.date,
      "time": item.time,
      "start_date": item.startDate,
      "start_time": item.startTime,
      "total": item.total,
      "reconciliation": ["id": reconciliationId]
    ]

    data["currency"] = BridgeSerialization.encodeToJSONObject(item.currency) ?? NSNull()
    data["is_balanced"] = BridgeSerialization.encodeToJSONObject(item.isBalanced) ?? NSNull()

    return data
  }

  static func wrapReconciliationListItem(_ item: ReconciliationItem) -> [String: Any]? {
    let reconciliationId = item.id.uuidString
    let data = reconciliationListItemPayload(item)

    let receiptWrapper: [String: Any] = [
      "id": reconciliationId,
      "standard": "standard",
      "operation_type": "reconciliation",
      "data": data,
      "reconciliation": ["id": reconciliationId],
      "created_at": NSNull(),
      "updated_at": NSNull()
    ]

    return [
      "receipt": receiptWrapper,
      "reconciliation_id": reconciliationId
    ]
  }

  static func reconciliationResponsePayload(_ receipt: ReconciliationResponse.Receipt) -> [String: Any]? {
    if let standardReceipt = try? receipt.content(type: ReconciliationReceipt.self) {
      return serializeReconciliationReceipt(standardReceipt)
    }

    if let turkeyReceipt = try? receipt.content(type: TurkeyReconciliationReceipt.self) {
      return BridgeSerialization.encodeToJSONObject(turkeyReceipt) as? [String: Any]
    }

    guard let rawPayload = BridgeSerialization.encodeToJSONObject(receipt) as? [String: Any] else {
      return nil
    }

    return (rawPayload["data"] as? [String: Any]) ?? rawPayload
  }

  static func extractReconciliationId(from payload: [String: Any]) -> String {
    if let reconciliation = payload["reconciliation"] as? [String: Any],
      let id = BridgeSerialization.stringValue(from: reconciliation["id"]),
      !id.isEmpty
    {
      return id
    }

    if let id = BridgeSerialization.stringValue(from: payload["id"]), !id.isEmpty {
      return id
    }

    return ""
  }

  static func serializeAuthenticationObjects(_ objects: AuthenticationObjects) -> [String: Any] {
    var payload: [String: Any] = [:]

    if let user = objects.user {
      payload["user"] = serializeUser(user)
    }

    if let terminal = objects.terminal {
      payload["terminal"] = serializeTerminal(terminal)
    }

    if objects.authenticator != nil {
      payload["requiresOtp"] = true
    }

    return payload
  }

  static func serializeUser(_ user: NearpayUser) -> [String: Any] {
    var payload: [String: Any] = [
      "name": user.info.name,
      "userUUID": user.id.uuidString,
    ]
    payload["mobile"] = user.info.mobile ?? NSNull()
    payload["email"] = user.info.email ?? NSNull()
    return payload
  }

  static func serializeTerminal(_ terminal: NearpayTerminal, tid: String? = nil, name: String? = nil) -> [String: Any] {
    let terminalId = terminal.id.uuidString
    let hasReaderToken = terminalHasReaderToken(terminal)

    var payload: [String: Any] = [
      "id": terminalId,
      "uuid": terminalId,
      "terminalUUID": terminalId,
      "userId": terminal.userID.uuidString,
      "userUUID": terminal.userID.uuidString,
      "hasReaderToken": hasReaderToken,
      "isReady": terminal.isReady,
    ]

    if let tid = tid ?? terminal.tid {
      payload["tid"] = tid
    }

    if let name = name ?? terminal.name {
      payload["name"] = name
    }

    return payload
  }

  static func terminalHasReaderToken(_ terminal: NearpayTerminal) -> Bool {
    let mirror = Mirror(reflecting: terminal)
    guard let tokenChild = mirror.children.first(where: { $0.label == "readerToken" }) else {
      return false
    }

    let tokenMirror = Mirror(reflecting: tokenChild.value)
    if tokenMirror.displayStyle == .optional {
      return tokenMirror.children.first != nil
    }

    return false
  }

  static func serializeTerminalListResponse(
    _ response: TerminalListResponse,
    userUUID: String
  ) -> [String: Any] {
    [
      "pagination": serializePagination(response.pagination),
      "terminals": response.terminalList.map { serializeUserTerminal($0, userUUID: userUUID) }
    ]
  }

  static func serializeUserTerminal(_ terminal: UserTerminal, userUUID: String) -> [String: Any] {
    var payload: [String: Any] = [
      "tid": terminal.tid,
      "uuid": terminal.id.uuidString,
      "busy": terminal.busy,
      "mode": terminal.mode ?? "UNKNOWN",
      "isLocked": terminal.isLocked,
      "hasProfile": terminal.hasProfile,
      "userUUID": userUUID,
    ]

    if let name = terminal.name {
      payload["name"] = name
    }

    if let merchant = terminal.merchant {
      payload["merchant"] = serializeTerminalMerchant(merchant)
    }

    return payload
  }

  static func serializeTerminalMerchant(_ merchant: TerminalMerchant) -> [String: Any] {
    var payload: [String: Any] = [
      "id": merchant.id,
      "name": serializeLocalizationField(merchant.name)
    ]

    payload["createdAt"] = merchant.createdAt ?? NSNull()

    return payload
  }

  static func serializeLocalizationField(_ field: LocalizationField) -> [String: Any] {
    [
      "arabic": field.arabic,
      "english": field.english
    ]
  }

  static func serializePagination(_ pagination: Pagination) -> [String: Any] {
    var payload: [String: Any] = [
      "current_page": pagination.currentPage ?? 1,
    ]

    if let totalPages = pagination.totalPages {
      payload["total_pages"] = totalPages
    }

    if let totalData = pagination.totalData {
      payload["total_data"] = totalData
    }

    return payload
  }

  static func flutterCamelCaseKey(_ key: String) -> String {
    guard key.contains("_") else { return key }
    let parts = key.split(separator: "_", omittingEmptySubsequences: false).map(String.init)
    guard let first = parts.first else { return key }
    var result = first
    for part in parts.dropFirst() where !part.isEmpty {
      result += part.prefix(1).uppercased() + part.dropFirst()
    }
    return result
  }

  static func camelCaseKeysDeep(_ value: Any) -> Any {
    if let dict = value as? [String: Any] {
      var converted: [String: Any] = [:]
      for (key, val) in dict {
        converted[flutterCamelCaseKey(key)] = camelCaseKeysDeep(val)
      }
      return converted
    }
    if let array = value as? [Any] {
      return array.map { camelCaseKeysDeep($0) }
    }
    return value
  }

  static func flutterJSONString(from object: Any) -> String? {
    guard JSONSerialization.isValidJSONObject(object),
      let data = try? JSONSerialization.data(withJSONObject: object, options: []),
      let json = String(data: data, encoding: .utf8)
    else {
      return nil
    }
    return json
  }
}
