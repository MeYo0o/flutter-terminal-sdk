import Foundation
import TerminalSDK

enum BridgeError: LocalizedError {
  case notInitialized
  case missingParameter(String)
  case invalidParameter(String)
  case methodUnavailable(String)
  case invalidUUID(String)

  var errorDescription: String? {
    switch self {
    case .notInitialized:
      return "Initialize the Nearpay Terminal SDK bridge before calling this method."
    case .missingParameter(let name):
      return "Missing parameter: \(name)."
    case .invalidParameter(let name):
      return "Invalid value for parameter: \(name)."
    case .methodUnavailable(let name):
      return "Method \(name) is not implemented."
    case .invalidUUID(let value):
      return "Invalid UUID string provided: \(value)."
    }
  }

  var code: String {
    switch self {
    case .notInitialized:
      return "E_NEARPAY_NOT_INITIALIZED"
    case .missingParameter:
      return "E_NEARPAY_MISSING_PARAMETER"
    case .invalidParameter:
      return "E_NEARPAY_INVALID_PARAMETER"
    case .methodUnavailable:
      return "E_NEARPAY_METHOD_UNAVAILABLE"
    case .invalidUUID:
      return "E_NEARPAY_INVALID_UUID"
    }
  }

  var nsError: NSError {
    NSError(
      domain: "NearpayTerminalSDK",
      code: code.hashValue,
      userInfo: [NSLocalizedDescriptionKey: errorDescription ?? code]
    )
  }
}

struct LocalizedDisplayPair {
  let titleEnglish: String
  let titleArabic: String
  let labelEnglish: String
  let labelArabic: String
}

private enum BridgeDisplayErrorSupport {
  static func displayError(from error: Error) -> DisplayError? {
    if let terminalError = error as? TerminalError {
      return terminalError.displayError
    }
    if let readerError = error as? ReaderError {
      return readerError.displayError
    }
    if let networkError = error as? TerminalNetworkError {
      return networkError.displayError
    }
    return nil
  }

  static func pair(from display: DisplayError) -> LocalizedDisplayPair {
    LocalizedDisplayPair(
      titleEnglish: display.title.english,
      titleArabic: display.title.arabic,
      labelEnglish: display.label.english,
      labelArabic: display.label.arabic
    )
  }
}

enum BridgeSerialization {
  private static let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  static func encodeToJSONObject<T: Encodable>(_ value: T) -> Any? {
    do {
      let data = try jsonEncoder.encode(value)
      return try JSONSerialization.jsonObject(with: data, options: [])
    } catch {
      return nil
    }
  }

  static func stringValue(from value: Any?) -> String? {
    let raw: String?
    switch value {
    case let string as String:
      raw = string
    case let string as NSString:
      raw = string as String
    default:
      raw = nil
    }

    guard let string = raw else { return nil }
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

enum BridgeErrorMapper {

  static func settledModuleReleasedResponse() -> [String: Any] {
    let code = "MODULE_RELEASED"
    let message = "Nearpay native module was released before the operation completed."
    return [
      "status": "error",
      "code": code,
      "type": code,
      "message": message,
      "nativeError": [
        "type": code,
        "message": message
      ]
    ]
  }

  static func responseHandlerError(
    code: String,
    message: String,
    underlyingError: Error? = nil
  ) -> [String: Any] {
    var payload: [String: Any] = [
      "status": "error",
      "code": code,
      "type": code,
      "message": message
    ]
    payload["nativeError"] =
      underlyingError.map { serializeNativeError($0, code: code, message: message) }
      ?? bridgeNativeError(code: code, message: message)
    return payload
  }

  static func bridgeNativeError(
    code: String,
    message: String,
    nativeType: String? = nil,
    details: [String: Any]? = nil
  ) -> [String: Any] {
    var payload: [String: Any] = [
      "type": nativeType ?? code,
      "message": message
    ]
    if let details, !details.isEmpty {
      payload["detail"] = details
    }
    return payload
  }

  static func dictionary(from pair: LocalizedDisplayPair) -> [String: Any] {
    return [
      "title": [
        "arabic": pair.titleArabic,
        "english": pair.titleEnglish
      ],
      "label": [
        "arabic": pair.labelArabic,
        "english": pair.labelEnglish
      ]
    ]
  }

  static func descriptiveDisplayPair(for error: Error) -> LocalizedDisplayPair {
    if let display = BridgeDisplayErrorSupport.displayError(from: error) {
      return BridgeDisplayErrorSupport.pair(from: display)
    }

    let label = errorMessage(from: error)
    return LocalizedDisplayPair(
      titleEnglish: "Error",
      titleArabic: "خطأ",
      labelEnglish: label,
      labelArabic: ""
    )
  }

  static func serializeDescriptiveErrorInfo(_ error: Error) -> [String: Any]? {
    guard BridgeDisplayErrorSupport.displayError(from: error) != nil else {
      return nil
    }

    let pair = descriptiveDisplayPair(for: error)
    return [
      "description": pair.labelEnglish,
      "displayError": dictionary(from: pair)
    ]
  }

  static func messageError(from error: Error) -> TerminalMessageError? {
    if let terminalError = error as? TerminalError {
      return terminalError.messageError
    }
    if let readerError = error as? ReaderError {
      return readerError.messageError
    }
    if let networkError = error as? TerminalNetworkError {
      return networkError.messageError
    }
    return nil
  }

  static func serializeMessageError(_ messageError: TerminalMessageError) -> [String: Any] {
    var payload: [String: Any] = [
      "type": messageError.code,
      "code_text": messageError.codeText,
      "statusCode": messageError.statusCode,
      "terminalPausedSeconds": messageError.terminalPausedSeconds,
      "level": messageError.level.rawValue,
      "source": messageError.source.english
    ]
    if let error = localizedDictionary(messageError.error) {
      payload["error"] = error
    }
    if let solution = localizedDictionary(messageError.solution) {
      payload["solution"] = solution
    }
    return payload
  }

  static func serializeNetworkErrorInfo(_ error: TerminalNetworkError) -> [String: Any] {
    let pair = BridgeDisplayErrorSupport.pair(from: error.displayError)
    return [
      "type": error.messageError.codeText,
      "displayError": dictionary(from: pair),
      "descriptive": [
        "description": pair.labelEnglish,
        "displayError": dictionary(from: pair)
      ]
    ]
  }

  static func serializeNativeError(
    _ error: Error,
    code: String? = nil,
    message: String? = nil,
    depth: Int = 0
  ) -> [String: Any] {
    if depth > 10 {
      return [
        "type": "NEARPAY_ERROR_SERIALIZATION_LIMIT",
        "message": message ?? "Native error (serialization depth limit)"
      ]
    }

    let resolvedMessage = message ?? errorMessage(from: error)
    let descriptive = serializeDescriptiveErrorInfo(error)

    if let bridgeError = error as? BridgeError {
      return bridgeNativeError(
        code: code ?? bridgeError.code,
        message: resolvedMessage,
        nativeType: bridgeError.code,
        details: [
          "description": bridgeError.errorDescription ?? resolvedMessage
        ]
      )
    }

    if let terminalError = error as? TerminalError,
       let payload = serializeTerminalError(
         terminalError,
         resolvedMessage: resolvedMessage,
         descriptive: descriptive,
         depth: depth
       ) {
      return payload
    }

    if let readerError = error as? ReaderError {
      return finalizeNativeError(
        base: [
          "type": "ReaderError",
          "message": resolvedMessage
        ],
        descriptive: descriptive ?? serializeDescriptiveErrorInfo(readerError),
        details: [
          "nativeType": String(describing: readerError)
        ],
        messageError: readerError.messageError
      )
    }

    if let networkError = error as? TerminalNetworkError {
      return finalizeNativeError(
        base: [
          "type": "networkFailure",
          "message": resolvedMessage
        ],
        descriptive: descriptive ?? serializeDescriptiveErrorInfo(networkError),
        details: serializeNetworkErrorInfo(networkError),
        messageError: networkError.messageError
      )
    }

    return finalizeNativeError(
      base: [
        "type": String(describing: type(of: error)),
        "message": resolvedMessage
      ],
      descriptive: descriptive
    )
  }

  private static func finalizeNativeError(
    base payload: [String: Any],
    descriptive: [String: Any]?,
    details extraDetails: [String: Any]? = nil,
    messageError: TerminalMessageError? = nil
  ) -> [String: Any] {
    var payload = payload
    if let descriptive {
      if let description = descriptive["description"] {
        payload["description"] = description
      }
      if let localizedMessage = descriptive["localizedMessage"] {
        payload["localizedMessage"] = localizedMessage
      }
      if let displayError = descriptive["displayError"] {
        payload["displayError"] = displayError
      }
    }
    var details = extraDetails ?? [:]
    if let messageError {
      details["messageError"] = serializeMessageError(messageError)
    }
    if !details.isEmpty {
      payload["detail"] = details
    }
    return payload
  }

  private static func serializeTerminalError(
    _ terminalError: TerminalError,
    resolvedMessage: String,
    descriptive: [String: Any]?,
    depth: Int
  ) -> [String: Any]? {
    switch terminalError {
    case .invalidRequest(let invalidError):
      return finalizeNativeError(
        base: [
          "type": "invalidRequest",
          "message": resolvedMessage
        ],
        descriptive: descriptive,
        details: ["invalidType": invalidType(of: invalidError)],
        messageError: terminalError.messageError
      )
    case .provisioningFailure(let readerError):
      return finalizeNativeError(
        base: [
          "type": "provisioningFailure",
          "message": resolvedMessage
        ],
        descriptive: descriptive,
        details: [
          "underlying": serializeNativeError(readerError, depth: depth + 1)
        ],
        messageError: terminalError.messageError
      )
    case .linkingFailure(let readerError):
      return finalizeNativeError(
        base: [
          "type": "linkingFailure",
          "message": resolvedMessage
        ],
        descriptive: descriptive,
        details: [
          "underlying": serializeNativeError(readerError, depth: depth + 1)
        ],
        messageError: terminalError.messageError
      )
    case .networkFailure(let networkError):
      return finalizeNativeError(
        base: [
          "type": "networkFailure",
          "message": resolvedMessage
        ],
        descriptive: descriptive,
        details: serializeNetworkErrorInfo(networkError),
        messageError: terminalError.messageError
      )
    @unknown default:
      return nil
    }
  }

  private static func invalidType(of invalidError: InvalidError) -> String {
    switch invalidError {
    case .missingDependencyObject: return "missingDependencyObject"
    case .terminalDisconnected: return "terminalDisconnected"
    case .userLoggedOut: return "userLoggedOut"
    case .userNotFound: return "userNotFound"
    case .unsupportedOperation: return "unsupportedOperation"
    case .invalidAmount: return "invalidAmount"
    case .invalidParameter: return "invalidParameter"
    case .invalidInstallmentsCount: return "invalidInstallmentsCount"
    case .invalidTipAmount: return "invalidTipAmount"
    case .transactionAlreadyInProgress: return "transactionAlreadyInProgress"
    case .routingSessionExpired: return "routingSessionExpired"
    case .notFound: return "notFound"
    case .locationPermissionDenied: return "locationPermissionDenied"
    @unknown default: return "invalidRequest"
    }
  }

  private static func localizedDictionary(_ value: LocalizedString) -> [String: Any]? {
    var payload: [String: Any] = [:]
    let english = value.english.trimmingCharacters(in: .whitespacesAndNewlines)
    let arabic = value.arabic.trimmingCharacters(in: .whitespacesAndNewlines)
    if !english.isEmpty {
      payload["english"] = english
    }
    if !arabic.isEmpty {
      payload["arabic"] = arabic
    }
    return payload.isEmpty ? nil : payload
  }

  static func errorMessage(from error: Error) -> String {
    if let display = BridgeDisplayErrorSupport.displayError(from: error) {
      let label = display.label.english.trimmingCharacters(in: .whitespacesAndNewlines)
      let title = display.title.english.trimmingCharacters(in: .whitespacesAndNewlines)
      if !label.isEmpty {
        return label
      }
      if !title.isEmpty {
        return title
      }
    }
    if let localized = error as? LocalizedError, let desc = localized.errorDescription {
      return desc
    }
    return String(describing: error)
  }
}
