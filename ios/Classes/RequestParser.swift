import Foundation
import TerminalSDK

enum RequestParser {

  static let bridgeKeyAliases: [String: String] = [
    "authorizationUuid": "authorizationUUID",
    "intentUuid": "intentUUID",
    "originalIntentId": "originalIntentID",
    "refundUuid": "refundUUID",
    "terminalId": "terminalID",
    "terminalUuid": "terminalUUID",
    "transactionUuid": "transactionUUID",
    "userUuid": "userUUID",
  ]

  static func bridgeShouldPreferRawKey(_ rawKey: String) -> Bool {
    !rawKey.contains("_")
  }

  static func toCamelCaseBridgeKey(_ key: String) -> String {
    var result = ""
    var upperNext = false
    for ch in key {
      if ch == "_" {
        upperNext = true
        continue
      }
      if upperNext {
        result.append(contentsOf: String(ch).uppercased())
        upperNext = false
      } else {
        result.append(ch)
      }
    }
    return result
  }

  static func normalizeBridgeKey(_ rawKey: String) -> String {
    let camelKey = toCamelCaseBridgeKey(rawKey)
    return bridgeKeyAliases[camelKey] ?? camelKey
  }

  static func coerceToStringKeyedDictionary(_ value: Any) -> [String: Any]? {
    if let d = value as? [String: Any] {
      return d
    }
    if let d = value as? NSDictionary {
      var out: [String: Any] = [:]
      for key in d.allKeys {
        guard let k = key as? String else { continue }
        out[k] = d.object(forKey: key)
      }
      return out
    }
    return nil
  }

  static func normalizeBridgeOperationValue(_ value: Any) -> Any {
    if value is NSNull {
      return value
    }
    if let arr = value as? [Any] {
      return arr.map { normalizeBridgeOperationValue($0) }
    }
    if let arr = value as? NSArray {
      var out: [Any] = []
      out.reserveCapacity(arr.count)
      for i in 0..<arr.count {
        out.append(normalizeBridgeOperationValue(arr[i]))
      }
      return out
    }
    guard let dict = coerceToStringKeyedDictionary(value) else {
      return value
    }

    let sortedKeys = dict.keys.sorted { lhs, rhs in
      let lhsUnderscore = lhs.contains("_")
      let rhsUnderscore = rhs.contains("_")
      if lhsUnderscore != rhsUnderscore {
        return !lhsUnderscore
      }
      return lhs < rhs
    }

    var normalized: [String: Any] = [:]
    for rawKey in sortedKeys {
      guard let rawValue = dict[rawKey] else { continue }
      let mappedKey = normalizeBridgeKey(rawKey)
      let mappedValue = normalizeBridgeOperationValue(rawValue)
      if normalized[mappedKey] != nil, !bridgeShouldPreferRawKey(rawKey) {
        continue
      }
      normalized[mappedKey] = mappedValue
    }
    return normalized
  }

  static func normalizeBridgeOperationArgs(_ args: NSDictionary?) -> NSDictionary {
    guard let args else {
      return NSDictionary()
    }
    let normalized = normalizeBridgeOperationValue(args)
    if let dict = normalized as? [String: Any] {
      return NSDictionary(dictionary: dict)
    }
    return NSDictionary()
  }

  static func makeTransactionListQuery(from dictionary: [String: Any]?) -> TransactionListQuery? {
    guard let dictionary = dictionary else { return nil }

    let pageNumber = intValue(from: dictionary["page"]
      ?? dictionary["pageNumber"]
      ?? dictionary["page_number"])
    let pageSize = intValue(from: dictionary["pageSize"]
      ?? dictionary["page_size"])
    let startDate = timeIntervalValue(from: dictionary["startDate"]
      ?? dictionary["start_date"])
    let endDate = timeIntervalValue(from: dictionary["endDate"]
      ?? dictionary["end_date"])
    let date = timeIntervalValue(from: dictionary["date"])
    let status = BridgeSerialization.stringValue(from: dictionary["status"])
    let isReconciled = boolValue(from: dictionary["isReconciled"]
      ?? dictionary["is_reconciled"])
    let reference = BridgeSerialization.stringValue(from: dictionary["customerReferenceNumber"]
      ?? dictionary["customer_reference_number"])

    return TransactionListQuery(
      pageNumber: pageNumber,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate,
      date: date,
      status: status,
      isReconciled: isReconciled,
      customerReferenceNumber: reference
    )
  }

  static func makeReconciliationListQuery(from dictionary: [String: Any]?) -> ReconciliationListQuery? {
    guard let dictionary = dictionary else { return nil }

    let pageNumber = intValue(from: dictionary["page"]
      ?? dictionary["pageNumber"]
      ?? dictionary["page_number"]) ?? 1
    let pageSize = intValue(from: dictionary["pageSize"]
      ?? dictionary["page_size"]) ?? 10
    let startDate = timeIntervalValue(from: dictionary["startDate"]
      ?? dictionary["start_date"])
    let endDate = timeIntervalValue(from: dictionary["endDate"]
      ?? dictionary["end_date"])

    return ReconciliationListQuery(
      pageNumber: pageNumber,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate
    )
  }

  static func makeTerminalListQuery(from dictionary: [String: Any]?) -> TerminalListQuery? {
    guard let dictionary = dictionary else { return nil }

    let pageNumber = intValue(from: dictionary["page"]
      ?? dictionary["pageNumber"]
      ?? dictionary["page_number"])
    let pageSize = intValue(from: dictionary["pageSize"]
      ?? dictionary["page_size"])
    let nameFilter: String?
    if let filter = dictionary["nameFilter"] as? String, !filter.isEmpty {
      nameFilter = filter
    } else if let filter = dictionary["name_filter"] as? String, !filter.isEmpty {
      nameFilter = filter
    } else {
      nameFilter = nil
    }

    return TerminalListQuery(pageNumber: pageNumber, pageSize: pageSize, nameFilter: nameFilter)
  }

  static func makeListQuery(from dictionary: [String: Any]?) -> ListQuery? {
    guard let dictionary = dictionary else { return nil }

    let pageNumber = intValue(from: dictionary["page"]
      ?? dictionary["pageNumber"]
      ?? dictionary["page_number"])
      .map(String.init)
    let pageSize = intValue(from: dictionary["limit"]
      ?? dictionary["pageSize"]
      ?? dictionary["page_size"])
      .map(String.init)

    return ListQuery(pageNumber: pageNumber, pageSize: pageSize)
  }

  static func parseSDKConfiguration(from configuration: NSDictionary) -> TerminalSDK.TerminalSDKConfiguration {
    let config = configuration as? [String: Any] ?? [:]

    return TerminalSDK.TerminalSDKConfiguration(
      country: resolveSdkCountry(from: config["country"]),
      environment: resolveSdkEnvironment(from: config["environment"])
    )
  }

  static func resolveSdkCountry(from value: Any?) -> TerminalCountry {
    guard let country = BridgeSerialization.stringValue(from: value)?.lowercased() else {
      return .sa
    }

    switch country {
    case "sa", "saudi", "saudiarabia":
      return .sa
    case "tr", "turkey":
      return .tr
    case "us", "usa", "unitedstates":
      return .us
    default:
      return .sa
    }
  }

  static func resolveSdkEnvironment(from value: Any?) -> TerminalEnvironment {
    guard let environment = BridgeSerialization.stringValue(from: value)?.lowercased() else {
      return .sandbox
    }

    switch environment {
    case "production", "prod":
      return .production
    case "internal", "local":
      return .local
    default:
      return .sandbox
    }
  }

  static func paymentType(from value: String) -> TerminalSDK.PaymentType? {
    switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "cash":
      return .cash
    case "card":
      return .card
    default:
      return nil
    }
  }

  static func invoiceItems(from value: Any?) -> [InvoiceItem]? {
    guard let rawItems = value as? [Any], !rawItems.isEmpty else {
      return nil
    }

    var items: [InvoiceItem] = []
    for rawItem in rawItems {
      guard let payload = rawItem as? [String: Any] else {
        return nil
      }
      guard let name = BridgeSerialization.stringValue(from: payload["name"]) else {
        return nil
      }
      guard
        let unitPrice = doubleValue(from: payload["unitPrice"]
          ?? payload["unit_price"]),
        unitPrice >= 0
      else {
        return nil
      }
      guard
        let quantity = intValue(from: payload["quantity"]),
        quantity > 0
      else {
        return nil
      }
      let vat = doubleValue(from: payload["vat"]) ?? 0
      items.append(
        InvoiceItem(name: name, unitPrice: unitPrice, quantity: quantity, vat: vat)
      )
    }

    return items
  }

  static func paymentCardScheme(from value: Any?) -> PaymentCardScheme? {
    guard let scheme = BridgeSerialization.stringValue(from: value) else { return nil }
    if let match = PaymentCardScheme(rawValue: scheme) {
      return match
    }

    let cleaned = scheme.replacingOccurrences(of: "_", with: "")
      .replacingOccurrences(of: " ", with: "")
      .lowercased()
    switch cleaned {
    case "undefined":
      return .undefined
    case "mada":
      return .mada
    case "visa":
      return .visa
    case "mastercard":
      return .mastercard
    case "maestro":
      return .maestro
    case "americanexpress":
      return .americanExpress
    case "gccnet":
      return .gccNet
    case "unionpay":
      return .unionPay
    case "jcb":
      return .jcb
    case "discover":
      return .discover
    case "nearpay":
      return .nearpay
    default:
      return PaymentCardScheme(rawValue: scheme.lowercased())
    }
  }

  static func intValue(from value: Any?) -> Int? {
    switch value {
    case let number as NSNumber:
      return number.intValue
    case let string as NSString:
      return Int(string as String)
    case let string as String:
      return Int(string)
    default:
      return nil
    }
  }

  static func uint64Value(from value: Any?) -> UInt64? {
    switch value {
    case let number as NSNumber:
      let numericValue = number.doubleValue
      guard numericValue.isFinite, numericValue >= 0, floor(numericValue) == numericValue else {
        return nil
      }
      return UInt64(numericValue)
    case let string as NSString:
      return UInt64(string as String)
    case let string as String:
      return UInt64(string)
    default:
      return nil
    }
  }

  static func doubleValue(from value: Any?) -> Double? {
    switch value {
    case let number as NSNumber:
      let numericValue = number.doubleValue
      return numericValue.isFinite ? numericValue : nil
    case let string as NSString:
      let numericValue = Double(string as String)
      return numericValue?.isFinite == true ? numericValue : nil
    case let string as String:
      let numericValue = Double(string)
      return numericValue?.isFinite == true ? numericValue : nil
    default:
      return nil
    }
  }

  static func timeIntervalValue(from value: Any?) -> TimeInterval? {
    switch value {
    case let number as NSNumber:
      return number.doubleValue
    case let string as String:
      let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
      if let numeric = Double(trimmed) {
        return numeric
      }
      return parsedDate(from: trimmed)?.timeIntervalSince1970
    default:
      return nil
    }
  }

  static func invalidDateKey(in dictionary: [String: Any]?) -> String? {
    guard let dictionary = dictionary else { return nil }
    for key in ["startDate", "endDate", "date"] {
      guard let value = dictionary[key], !(value is NSNull) else { continue }
      if timeIntervalValue(from: value) == nil {
        return key
      }
    }
    return nil
  }

  private static func parsedDate(from value: String) -> Date? {
    for formatter in isoDateFormatters {
      if let date = formatter.date(from: value) {
        return date
      }
    }
    return calendarDayFormatter.date(from: value)
  }

  private static let isoDateFormatters: [ISO8601DateFormatter] = {
    let internetDateTime = ISO8601DateFormatter()
    internetDateTime.formatOptions = [.withInternetDateTime]
    let fractionalSeconds = ISO8601DateFormatter()
    fractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return [internetDateTime, fractionalSeconds]
  }()

  private static let calendarDayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  static func boolValue(from value: Any?) -> Bool? {
    switch value {
    case let number as NSNumber:
      return number.boolValue
    case let string as String:
      let lowercased = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
      if ["true", "1", "yes"].contains(lowercased) { return true }
      if ["false", "0", "no"].contains(lowercased) { return false }
      return nil
    default:
      return nil
    }
  }

  static func uuidValue(from value: Any?) -> UUID? {
    if let string = value as? String {
      return UUID(uuidString: string)
    }

    if let string = value as? NSString {
      return UUID(uuidString: string as String)
    }

    return nil
  }

  static func rawStringValue(from value: Any?) -> String? {
    switch value {
    case let string as String:
      return string
    case let string as NSString:
      return string as String
    default:
      return nil
    }
  }

  static func dictionary(from params: NSDictionary?) -> [String: Any]? {
    return params as? [String: Any]
  }
}
